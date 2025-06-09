package sitegen

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
import "./vendor/cmark"

BLOG_ARTICLES_DIR :: "site/blog/"
PAGES_DIR :: "site/pages/"
IMAGES_DIR :: "site/images/"
THEME_STATIC_DIR :: "mytheme/static/"

DEFAULT_LANG :: "en"

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
    return cmark.markdown_to_html_from_string(article.md_content, {.Unsafe})
}

Args :: struct {
    // pos_arg1: string `args:"pos=0,required" usage:"Positional arg 1"`,
    // pos_arg2: string `args:"pos=1,required" usage:"Positional arg 2"`,
    output: string `usage:"Output directory"`,
}

main :: proc() {
    args: Args
    flags.parse_or_exit(&args, os.args, style = .Unix)
    if args.output == "" {
        args.output = "odin_output"
    }
    output_dir := args.output
    fmt.println(args)

    context.logger = log.create_console_logger()

    parsed, _ := json.parse_string(
        `{
            "SITEURL": "https://eliasdorneles.com",
            "SITENAME": "Elias Dorneles",
            "MENUITEMS": [
                {"title": "Blog", "url": ""},
                {"title": "Today I Learned...", "url": "til"},
                {"title": "About me", "url": "pages/about.html"},
            ]
        }`,
    )
    defer json.destroy_value(parsed)
    ctx := parsed.(json.Object)
    // ctx["FEED_RSS"] = "feed.xml"
    // ctx["FEED_ATOM"] = "atom.xml"

    env: Environment

    // let's now render the blog articles
    articles, ok := load_articles()
    slice.reverse_sort_by(
        articles[:],
        proc(a: Article, b: Article) -> bool {return a.date < b.date},
    )
    if ok {
        for &article in articles {
            temp_ctx := clone_context(&ctx)
            year, month, day := extract_ymd(article.date)
            article_obj: json.Object
            article_obj["title"] = article.title
            article_obj["slug"] = article.slug
            article_obj["date"] = article.date
            article_obj["author"] = article.author
            html_filename := fmt.aprintf("%s.html", article.slug)
            article_obj["url"] = fmt.aprintf("../../../%s", html_filename)
            article_obj["content"] = render_article_content(&article)
            temp_ctx["article"] = article_obj

            // TODO: populate .translations based on articles sharing
            // same slug but with different lang

            out_dir_path := filepath.join({args.output, year, month, day})
            if !makedirs(out_dir_path) {
                fmt.eprintln("Error attempting to create dir:", out_dir_path)
            }
            target_path := filepath.join({out_dir_path, html_filename})
            rendered, ok := render_template(&env, "article.html", &temp_ctx)
            if ok {
                bytes_to_write := transmute([]u8)rendered
                if !os.write_entire_file(target_path, bytes_to_write) {
                    fmt.eprintln("Error writing file:", target_path)
                }
                fmt.println("Wrote", target_path)
            } else {
                log.error("error rendering template", rendered)
            }
            // break // DEBUG: uncomment to stop at the first article
        }
    } else {
        fmt.eprintln("error loading articles")
    }
    fmt.println("All done")
}
