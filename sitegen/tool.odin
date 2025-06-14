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

SUMMARY_MAX_LENGTH :: 2 // number of paragraphs to include in summary

Article :: struct {
    title:      string,
    date:       string,
    filepath:   string,
    slug:       string,
    lang:       string,
    md_content: string,
    author:     string,
    template:   string,
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
            } else if key == "Template" {
                article.template = value
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

load_pages :: proc() -> (pages: [dynamic]Article, load_ok: bool) {
    page_path_list, err := filepath.glob("site/pages/*.md")
    if err != nil {
        return nil, false
    }
    for page_path in page_path_list {
        bytes_content := os.read_entire_file(page_path) or_return
        page: Article
        page.filepath = page_path
        page.slug = slug_from_path(page_path)
        load_article_from_string(&page, string(bytes_content)) or_return
        append(&pages, page)
    }
    return pages, true
}

get_page_url :: proc(page: ^Article) -> string {
    return fmt.aprintf("pages/%s.html", page.slug)
}

Options :: struct {
    output:      string `usage:"Output directory"`,
    config_file: string `usage:"Config file"`,
    local:       bool `usage:"Use localhost:8000 as SITEURL"`,
}

load_config :: proc(config_file: string, args: ^Options) -> (json.Object, bool) {
    if bytes_content, ok := os.read_entire_file(config_file); ok {
        if parsed, err := json.parse_string(string(bytes_content)); err == nil {
            config := parsed.(json.Object)

            cloned_config := json.clone_value(
                config,
                allocator = context.temp_allocator,
            ).(json.Object)

            if args.local {
                cloned_config["SITEURL"] = "http://localhost:8000"
            }

            return cloned_config, true
        } else {
            log.error("Error parsing config file:", config_file)
        }
    }
    log.error("Error loading config file:", config_file)
    return nil, false
}

// Get the filename for an article based on its slug and language
get_article_filename :: proc(article: ^Article) -> string {
    if article.lang == DEFAULT_LANG {
        return fmt.aprintf("%s.html", article.slug)
    } else {
        return fmt.aprintf("%s-%s.html", article.slug, article.lang)
    }
}

// Get the URL for an article based on its date, slug and language
get_article_url :: proc(article: ^Article) -> string {
    year, month, day := extract_ymd(article.date)
    return fmt.aprintf("%s/%s/%s/%s", year, month, day, get_article_filename(article))
}

// Group articles by slug to find translations
group_articles_by_slug :: proc(articles: []Article) -> map[string][dynamic]Article {
    groups := make(map[string][dynamic]Article)
    for article in articles {
        if articles, exists := groups[article.slug]; exists {
            append(&articles, article)
            groups[article.slug] = articles
        } else {
            articles := make([dynamic]Article)
            append(&articles, article)
            groups[article.slug] = articles
        }
    }
    return groups
}

// Create translations list for an article
create_translations :: proc(article: ^Article, translations: []Article) -> json.Array {
    result := make(json.Array)
    for &translation in translations {
        if translation.lang != article.lang {
            translation_obj: json.Object
            translation_obj["lang"] = translation.lang
            translation_obj["url"] = get_article_url(&translation)
            append(&result, translation_obj)
        }
    }
    return result
}

main :: proc() {
    args: Options
    flags.parse_or_exit(&args, os.args, style = .Unix)

    if args.output == "" {
        args.output = "output_sitegen"
    }
    if args.config_file == "" {
        args.config_file = "config_sitegen.json"
    }

    fmt.println(args)
    context.logger = log.create_console_logger()

    // Load configuration
    config, config_ok := load_config(args.config_file, &args)
    if !config_ok {
        fmt.eprintln("Error loading config file:", args.config_file)
        fmt.eprintfln("config: %s config_ok: %v", args.config_file, config_ok)
        return
    }

    ctx := config
    env: Environment
    defer destroy_env(&env)

    count_files_written := 0

    // Process pages first
    pages, pages_ok := load_pages()
    if pages_ok {
        for &page in pages {
            temp_ctx := clone_context(&ctx)
            page_obj: json.Object
            page_obj["title"] = page.title
            page_obj["slug"] = page.slug
            page_obj["date"] = page.date
            page_obj["author"] = page.author
            page_obj["url"] = get_page_url(&page)
            page_obj["content"] = render_article_content(&page)

            temp_ctx["page"] = page_obj
            temp_ctx["rel_source_path"] = fmt.aprintf("site/pages/%s.md", page.slug)

            out_dir_path := filepath.join({args.output, "pages"})
            if !makedirs(out_dir_path) {
                fmt.eprintln("Error attempting to create dir:", out_dir_path)
            }
            target_path := filepath.join(
                {out_dir_path, fmt.aprintf("%s.html", page.slug)},
            )

            template_name := page.template if page.template != "" else "page.html"
            if template_name != "page.html" && !strings.has_suffix(template_name, ".html") {
                template_name = fmt.aprintf("%s.html", template_name)
            }
            rendered, ok := render_template(&env, template_name, &temp_ctx)
            if !ok {
                fmt.eprintln("Error rendering page:", page.slug)
                continue
            }
            if !os.write_entire_file(target_path, transmute([]u8)rendered) {
                fmt.eprintln("Error writing page:", target_path)
                continue
            }
            count_files_written += 1
        }
    }
    fmt.printfln("Rendered %d pages", count_files_written)

    // let's now render the blog articles
    articles, ok := load_articles()
    slice.reverse_sort_by(
        articles[:],
        proc(a: Article, b: Article) -> bool {return a.date < b.date},
    )
    object_list: json.Array
    if ok {
        // Group articles by slug to find translations
        article_groups := group_articles_by_slug(articles[:])
        defer {
            for _, group in article_groups {
                delete(group)
            }
            delete(article_groups)
        }

        for &article in articles {
            temp_ctx := clone_context(&ctx)
            year, month, day := extract_ymd(article.date)
            article_obj: json.Object
            article_obj["title"] = article.title
            article_obj["slug"] = article.slug
            // this is a hack to add timezone info to complete the timestamp:
            article_obj["date"] = fmt.aprintf("%s:00+02:00", article.date)
            article_obj["author"] = article.author
            article_obj["url"] = get_article_url(&article)
            article_obj["content"] = render_article_content(&article)
            article_obj["_summary"] = generate_article_summary(&article)

            // Add translations if any exist
            if translations, exists := article_groups[article.slug]; exists {
                article_obj["translations"] = create_translations(
                    &article,
                    translations[:],
                )
            }

            temp_ctx["article"] = article_obj
            temp_ctx["rel_source_path"] = fmt.aprintf("site/blog/%s.md", article.slug)

            // Only add default language articles to the index page
            if article.lang == DEFAULT_LANG {
                append(&object_list, article_obj)
            }

            out_dir_path := filepath.join({args.output, year, month, day})
            if !makedirs(out_dir_path) {
                fmt.eprintln("Error attempting to create dir:", out_dir_path)
            }
            target_path := filepath.join({out_dir_path, get_article_filename(&article)})

            template_name :=
                article.template if article.template != "" else "article.html"
            if template_name != "article.html" && !strings.has_suffix(template_name, ".html") {
                template_name = fmt.aprintf("%s.html", template_name)
            }
            rendered, ok := render_template(&env, template_name, &temp_ctx)
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
