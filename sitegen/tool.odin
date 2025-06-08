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

BLOG_ARTICLES_DIR :: "site/blog/"
PAGES_DIR :: "site/pages/"
IMAGES_DIR :: "site/images/"
EXTRA_DIR :: "site/images/"

DEFAULT_LANG :: "en"

Article :: struct {
    title:      string,
    date:       string,
    filepath:   string,
    slug:       string,
    lang:       string,
    md_content: string,
    // author: string, // we can hardcode this one
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

Args :: struct {
    // pos_arg1: string `args:"pos=0,required" usage:"Positional arg 1"`,
    // pos_arg2: string `args:"pos=1,required" usage:"Positional arg 2"`,
    output: string `usage:"Output directory"`,
}

main :: proc() {
    args: Args
    flags.parse_or_exit(&args, os.args, style = .Unix)
    if args.output == "" {
        args.output = "output"
    }
    output_dir := args.output
    fmt.println(args)

    context.logger = log.create_console_logger()

    parsed, _ := json.parse_string(
        `{
            "SITEURL": "https://eliasdorneles.com",
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
    articles, ok := load_articles()
    slice.reverse_sort_by(
        articles[:],
        proc(a: Article, b: Article) -> bool {return a.date < b.date},
    )
    if ok {
        fmt.println("Loaded articles:")
        for article in articles {
            fmt.printfln(
                " -> Title: %s, Slug: %s, Date: %s, Lang: %s",
                article.title,
                article.slug,
                article.date,
                article.lang,
            )
        }
    } else {
        fmt.eprintln("error loading articles")
    }
}
