package sitegen

import "./vendor/cmark"
import "core:c/libc"
import "core:encoding/json"
import "core:flags"
import "core:fmt"
import "core:log"
import "core:math"
import "core:os"
import "core:path/filepath"
import "core:slice"
import "core:strings"
import "core:time"

BLOG_ARTICLES_DIR :: "site/blog/"
PAGES_DIR :: "site/pages/"
IMAGES_DIR :: "site/images/"
THEME_STATIC_DIR :: "mytheme/static/"

DEFAULT_LANG :: "en"

SUMMARY_MAX_LENGTH :: 1 // number of paragraphs to include in summary

Article :: struct {
    title:      string,
    date:       string,
    filepath:   string,
    slug:       string,
    lang:       string,
    md_content: string,
    author:     string,
}

extract_ymd :: proc(date: string) -> (string, string, string) {
    return date[:4], date[5:][:2], date[8:][:2]
}

makedirs :: proc(dir_path: string) -> bool {
    if os.exists(dir_path) && os.is_dir(dir_path) {
        return true
    }
    if dir_path == "" {
        return false
    }
    base_dir, _basename := filepath.split(strings.trim_right(dir_path, "/"))
    if !os.exists(base_dir) {
        makedirs(base_dir)
    }
    if os.make_directory(dir_path) != nil {
        return false
    }
    return true
}

load_article_from_string :: proc(article: ^Article, raw_content: string) -> bool {
    metadata_lines: [dynamic]string
    markdown_content: string
    defer delete(metadata_lines)

    line: string
    line_start_index: int
    eol: bool
    for char, index in raw_content {
        if char == '\n' {
            if eol {
                // two subsequent newlines means the end of metadata section
                if len(raw_content) < index + 10 {
                    log.error("Error: article missing metadata or is too short")
                    return false
                }
                article.md_content = raw_content[index + 1:]
                article.lang = article.lang if article.lang != "" else DEFAULT_LANG
                return true
            }
            line = raw_content[line_start_index:index]
            line_split := strings.split_n(line, ":", 2)
            defer delete(line_split)

            key, value := line_split[0], strings.trim_space(line_split[1])
            if key == "Title" {
                article.title = value
            } else if key == "Date" {
                article.date = value
            } else if key == "Slug" {
                article.slug = value
            } else if key == "Lang" {
                article.lang = value
            } else if key == "Author" {
                article.author = value
            }
            line_start_index = index + 1
            eol = true
        } else {
            eol = false
        }
    }

    log.error(
        "Article is mal-formed, missing sep between metadata and content: ",
        article,
    )
    return false
}

slug_from_path :: proc(path: string) -> string {
    _dir, filename := filepath.split(path)
    return filename[:len(filename) - len(".md")]
}

load_articles :: proc() -> (blog_articles: [dynamic]Article, load_ok: bool) {
    article_path_list, err := filepath.glob("site/blog/*.md")
    if err != nil {
        return nil, false
    }
    for article_path in article_path_list {
        bytes_content := os.read_entire_file(article_path) or_return
        article: Article
        article.filepath = article_path
        article.slug = slug_from_path(article_path)
        load_article_from_string(&article, string(bytes_content)) or_return
        append(&blog_articles, article)

    }
    return blog_articles, true
}

render_article_content :: proc(article: ^Article) -> string {
    md_content, _ := strings.replace_all(article.md_content, "{static}", "../../../")
    return cmark.markdown_to_html_from_string(md_content, {.Unsafe})
}

clean_html_summary :: proc(html: string) -> string {
    builder: strings.Builder
    defer strings.builder_destroy(&builder)

    in_tag := false
    tag_buffer: strings.Builder
    defer strings.builder_destroy(&tag_buffer)

    seen_image := false

    for char in html {
        if char == '<' {
            in_tag = true
            strings.write_rune(&tag_buffer, char)
            continue
        }
        if char == '>' {
            in_tag = false
            tag := strings.to_string(tag_buffer)
            if strings.has_prefix(tag, "<img") {
                if !seen_image {
                    strings.write_string(&builder, tag)
                    strings.write_rune(&builder, '>')
                    seen_image = true
                }
            } else {
                strings.write_string(&builder, tag)
                strings.write_rune(&builder, '>')
            }
            strings.builder_reset(&tag_buffer)
            continue
        }
        if in_tag {
            strings.write_rune(&tag_buffer, char)
        } else {
            strings.write_rune(&builder, char)
        }
    }

    result := strings.to_string(builder)
    result = strings.trim_space(result)
    if strings.has_suffix(result, "<p></p>") {
        result = result[:len(result) - 7]
    }
    return strings.clone_from(result, allocator = context.temp_allocator)
}

generate_article_summary :: proc(article: ^Article) -> string {
    // First try to find PELICAN_END_SUMMARY marker
    if end_marker := strings.index(article.md_content, "PELICAN_END_SUMMARY");
       end_marker != -1 {
        summary_md := article.md_content[:end_marker]
        html := cmark.markdown_to_html_from_string(summary_md, {.Unsafe})
        return clean_html_summary(html)
    }

    // Otherwise take first SUMMARY_MAX_LENGTH paragraphs and first image
    paragraphs := strings.split(
        article.md_content,
        "\n\n",
        allocator = context.temp_allocator,
    )
    if len(paragraphs) == 0 {
        return ""
    }

    // Find the first image paragraph
    first_image_idx := -1
    for paragraph, idx in paragraphs {
        if strings.has_prefix(strings.trim_space(paragraph), "![") {
            first_image_idx = idx
            break
        }
    }

    // Take first SUMMARY_MAX_LENGTH paragraphs
    summary_paragraphs: [dynamic]string
    defer delete(summary_paragraphs)
    for i in 0 ..< min(SUMMARY_MAX_LENGTH, len(paragraphs)) {
        append(&summary_paragraphs, paragraphs[i])
    }

    // If we found an image and it's not already included in the summary, add it
    if first_image_idx != -1 && first_image_idx >= SUMMARY_MAX_LENGTH {
        append(&summary_paragraphs, paragraphs[first_image_idx])
    }

    summary_md := strings.join(
        summary_paragraphs[:],
        "\n\n",
        allocator = context.temp_allocator,
    )
    html := cmark.markdown_to_html_from_string(summary_md, {.Unsafe})
    return clean_html_summary(html)
}

Options :: struct {
    output:      string `usage:"Output directory"`,
    config_file: string `usage:"Config file"`,
}

main :: proc() {
    args: Options
    flags.parse_or_exit(&args, os.args, style = .Unix)
    if args.output == "" {
        args.output = "odin_output"
    }
    if args.config_file == "" {
        args.config_file = "config_sitegen.json"
    }
    output_dir := args.output
    fmt.println(args)

    context.logger = log.create_console_logger()

    config_parsed: json.Value
    if config_data, ok := os.read_entire_file(args.config_file); ok {
        err: json.Error
        if config_parsed, err = json.parse(config_data); err != nil {
            fmt.eprintf("Couldn't load JSON from file %s, exiting", args.config_file)
            os.exit(1)
        }
    } else {
        fmt.eprintf("Couldn't read file %s, exiting", args.config_file)
        os.exit(1)
    }
    defer json.destroy_value(config_parsed)

    ctx := config_parsed.(json.Object)

    env: Environment

    // let's now render the blog articles
    articles, ok := load_articles()
    slice.reverse_sort_by(
        articles[:],
        proc(a: Article, b: Article) -> bool {return a.date < b.date},
    )
    count_files_written: int
    object_list: json.Array
    if ok {
        for &article in articles {
            temp_ctx := clone_context(&ctx)
            year, month, day := extract_ymd(article.date)
            article_obj: json.Object
            article_obj["title"] = article.title
            article_obj["slug"] = article.slug
            // this is a hack to add timezone info to complete the timestamp:
            article_obj["date"] = fmt.aprintf("%s:00+02:00", article.date)
            article_obj["author"] = article.author
            html_filename := fmt.aprintf("%s.html", article.slug)
            article_obj["url"] = fmt.aprintf("../../../%s", html_filename)
            article_obj["content"] = render_article_content(&article)
            article_obj["_summary"] = generate_article_summary(&article)
            temp_ctx["article"] = article_obj
            temp_ctx["rel_source_path"] = fmt.aprintf("site/blog/%s.md", article.slug)

            append(&object_list, article_obj)

            // TODO: populate .translations based on articles sharing
            // same slug but with different lang

            out_dir_path := filepath.join({args.output, year, month, day})
            if !makedirs(out_dir_path) {
                fmt.eprintln("Error attempting to create dir:", out_dir_path)
            }
            target_path := filepath.join({out_dir_path, html_filename})
            rendered, ok := render_template(&env, "article.html", &temp_ctx)
            if ok {
                // Replace {static} with relative path for articles
                rendered, _ = strings.replace_all(rendered, "{static}", "../../../")
                bytes_to_write := transmute([]u8)rendered
                if !os.write_entire_file(target_path, bytes_to_write) {
                    fmt.eprintln("Error writing file:", target_path)
                }
                count_files_written += 1
            } else {
                log.error("error rendering template", rendered)
            }
            // break // DEBUG: uncomment to stop at the first article
        }
    } else {
        fmt.eprintln("error loading articles")
    }

    // Generate index page
    index_ctx := clone_context(&ctx)
    articles_page: json.Object
    articles_page["object_list"] = object_list
    index_ctx["articles_page"] = articles_page
    index_ctx["articles"] = object_list // for backwards compatibility

    if rendered, ok := render_template(&env, "index.html", &index_ctx); ok {
        // Remove {static} for index page
        rendered, _ = strings.replace_all(rendered, "{static}", "")
        target_path := filepath.join({args.output, "index.html"})
        bytes_to_write := transmute([]u8)rendered
        if !os.write_entire_file(target_path, bytes_to_write) {
            fmt.eprintln("Error writing index file:", target_path)
        } else {
            count_files_written += 1
        }
    } else {
        log.error("error rendering index template", rendered)
    }

    fmt.printfln("\nWrote %d files!\n", count_files_written)

    makedirs(filepath.join({args.output, "theme"}))

    run_cmdf :: proc(cmdf: string, cmdf_args: ..any) {
        cmd := fmt.aprintf(cmdf, ..cmdf_args)
        libc.system(strings.clone_to_cstring(cmd))
    }

    // TODO: consider writing a portable version of these:
    fmt.println("Copying assets...")
    run_cmdf("cp --recursive ./site/images %s/", args.output)
    run_cmdf("cp --recursive mytheme/static/* %s/theme/", args.output)
    run_cmdf("cp ./site/extra/CNAME %s/CNAME", args.output)

    fmt.printfln("\nAll done!")
}
