package site_manage

import "core:c/libc"
import "core:flags"
import "core:fmt"
import "core:log"
import "core:math"
import "core:os"
import "core:path/filepath"
import "core:strings"
import "core:time"

Options :: struct {
    action:       string `args:"pos=0,required" usage:"The action to take: new-post or auto-rename-drafts"`,
    articles_dir: string `usage:"Blog articles directory"`,
}

POST_TEMPLATE :: `Title: %s
Date: %s
Author: Elias Dorneles
Status: draft

Write here...
`


Article_Metadata :: struct {
    title:  string,
    date:   string,
    author: string,
    status: string,
}

// Convert a title to a URL-friendly slug
title_to_slug :: proc(title: string) -> string {
    builder: strings.Builder
    defer strings.builder_destroy(&builder)

    last_was_space := true // Track if the last character was a space to avoid multiple hyphens

    for char in title {
        switch {
        case char >= 'a' && char <= 'z' || char >= '0' && char <= '9':
            strings.write_rune(&builder, char)
            last_was_space = false
        case char >= 'A' && char <= 'Z':
            strings.write_rune(&builder, char + 32) // Convert to lowercase
            last_was_space = false
        case char == ' ' || char == '\t':
            if !last_was_space {
                strings.write_rune(&builder, '-')
                last_was_space = true
            }
        case char == 'á' ||
             char == 'à' ||
             char == 'ã' ||
             char == 'â' ||
             char == 'Á' ||
             char == 'À' ||
             char == 'Ã' ||
             char == 'Â':
            strings.write_rune(&builder, 'a')
            last_was_space = false
        case char == 'é' || char == 'ê' || char == 'É' || char == 'Ê':
            strings.write_rune(&builder, 'e')
            last_was_space = false
        case char == 'í' || char == 'Í':
            strings.write_rune(&builder, 'i')
            last_was_space = false
        case char == 'ó' ||
             char == 'õ' ||
             char == 'ô' ||
             char == 'Ó' ||
             char == 'Õ' ||
             char == 'Ô':
            strings.write_rune(&builder, 'o')
            last_was_space = false
        case char == 'ú' || char == 'Ú':
            strings.write_rune(&builder, 'u')
            last_was_space = false
        case char == 'ç' || char == 'Ç':
            strings.write_rune(&builder, 'c')
            last_was_space = false
        case:
            // Skip other special characters
            continue
        }
    }

    result := strings.clone_from(strings.to_string(builder))
    // Remove trailing hyphen if present
    if strings.has_suffix(result, "-") {
        result = result[:len(result) - 1]
    }
    return result
}

// Generate filename for an article based on its title
gen_article_filename :: proc(title: string, articles_dir: string) -> string {
    slug := title_to_slug(title)
    defer delete(slug)
    return filepath.join({articles_dir, fmt.aprintf("%s.md", slug)})
}

// Create a new blog post
new_post :: proc(articles_dir: string) {
    title := "New Blog Post"
    now := time.now()
    //date := time.format(now, "%Y-%m-%d %H:%M")
    buf: [time.MIN_YYYY_DATE_LEN]u8
    date := fmt.aprintf(
        "%s %s",
        time.to_string_yyyy_mm_dd(now, buf[:]),
        time.to_string_hms(now, buf[:]),
    )

    content := fmt.aprintf(POST_TEMPLATE, title, date)
    filename := gen_article_filename(title, articles_dir)

    if os.write_entire_file(filename, transmute([]u8)content) {
        fmt.println("Created new post:", filename)
        cmd := fmt.aprintf("vim %s", filename)
        defer delete(cmd)
        libc.system(strings.unsafe_string_to_cstring(cmd))
    } else {
        fmt.eprintln("Failed to create post:", filename)
    }
}

// Parse metadata from an article file
parse_metadata :: proc(content: string) -> (Article_Metadata, bool) {
    metadata: Article_Metadata

    lines := strings.split_lines(content)
    defer delete(lines)

    for line in lines {
        line := strings.trim_space(line)
        if len(line) == 0 {
            break
        }

        if colon_idx := strings.index(line, ":"); colon_idx != -1 {
            key := strings.trim_space(line[:colon_idx])
            value := strings.trim_space(line[colon_idx + 1:])

            switch strings.to_lower(key) {
            case "title":
                metadata.title = value
            case "date":
                metadata.date = value
            case "author":
                metadata.author = value
            case "status":
                metadata.status = value
            }
        }
    }

    return metadata, metadata.title != ""
}

// Find drafts that need renaming
find_drafts_needing_renaming :: proc(
    articles_dir: string,
) -> (
    old_paths: [dynamic]string,
    new_paths: [dynamic]string,
) {
    dir, open_err := os.open(articles_dir)
    if open_err != nil {
        fmt.eprintln("Failed to open directory:", open_err)
        return
    }
    defer os.close(dir)

    entries, read_err := os.read_dir(dir, 0)
    if read_err != nil {
        fmt.eprintln("Failed to read directory:", read_err)
        return
    }
    defer os.file_info_slice_delete(entries)

    for entry in entries {
        if !entry.is_dir {
            filepath := filepath.join({articles_dir, entry.name})
            if content, ok := os.read_entire_file(filepath); ok {
                if metadata, ok := parse_metadata(string(content)); ok {
                    expected_filename := gen_article_filename(
                        metadata.title,
                        articles_dir,
                    )
                    if metadata.status == "draft" && expected_filename != filepath {
                        append(&old_paths, filepath)
                        append(&new_paths, expected_filename)
                    }
                }
                delete(content)
            }
        }
    }

    return
}

// Rename draft articles to match their titles
rename_drafts :: proc(articles_dir: string) {
    old_paths, new_paths := find_drafts_needing_renaming(articles_dir)
    defer delete(old_paths)
    defer delete(new_paths)

    for i in 0 ..< len(old_paths) {
        fmt.println("Will move", old_paths[i], "to", new_paths[i])
        if err := os.rename(old_paths[i], new_paths[i]); err != nil {
            fmt.eprintln("Failed to rename:", old_paths[i], "->", new_paths[i])
        }
    }
}

main :: proc() {
    args: Options
    flags.parse_or_exit(&args, os.args, style = .Unix)
    fmt.println(args)
    if args.articles_dir == "" {
        args.articles_dir = "site/blog" // Remove trailing slash to match test expectations
    }

    switch args.action {
    case "new-post":
        new_post(args.articles_dir)
    case "auto-rename-drafts":
        rename_drafts(args.articles_dir)
    case:
        fmt.eprintln("Unknown action:", args.action)
        os.exit(1)
    }
}
