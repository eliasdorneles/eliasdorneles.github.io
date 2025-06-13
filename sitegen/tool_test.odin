package sitegen

import "core:strings"
import "core:testing"

@(test)
test_generate_article_summary_with_marker :: proc(t: ^testing.T) {
    article := Article {
        md_content = "First paragraph\n\nSecond paragraph\n\nPELICAN_END_SUMMARY\n\nThird paragraph",
    }
    summary := generate_article_summary(&article)
    expected := "<p>First paragraph</p>\n<p>Second paragraph</p>\n"
    testing.expect_value(t, summary, expected)
}

@(test)
test_generate_article_summary_without_marker :: proc(t: ^testing.T) {
    article := Article {
        md_content = "First paragraph\n\nSecond paragraph\n\nThird paragraph",
    }
    summary := generate_article_summary(&article)
    expected := "<p>First paragraph</p>\n"
    testing.expect_value(t, summary, expected)
}

@(test)
test_generate_article_summary_empty :: proc(t: ^testing.T) {
    article := Article {
        md_content = "",
    }
    summary := generate_article_summary(&article)
    expected := ""
    testing.expect_value(t, summary, expected)
}

@(test)
test_generate_article_summary_markdown_formatting :: proc(t: ^testing.T) {
    article := Article {
        md_content = "**Bold** and *italic* text\n\nSecond paragraph",
    }
    summary := generate_article_summary(&article)
    expected := "<p><strong>Bold</strong> and <em>italic</em> text</p>\n"
    testing.expect_value(t, summary, expected)
}

@(test)
test_generate_article_summary_with_links :: proc(t: ^testing.T) {
    article := Article {
        md_content = "Check out [my site](https://example.com)\n\nSecond paragraph",
    }
    summary := generate_article_summary(&article)
    expected := "<p>Check out <a href=\"https://example.com\">my site</a></p>\n"
    testing.expect_value(t, summary, expected)
}

@(test)
test_generate_article_summary_with_code :: proc(t: ^testing.T) {
    article := Article {
        md_content = "Here's some code:\n```python\nprint('hello')\n```\n\nSecond paragraph",
    }
    summary := generate_article_summary(&article)
    expected := "<p>Here's some code:</p>\n<pre><code class=\"language-python\">print('hello')\n</code></pre>\n"
    testing.expect_value(t, summary, expected)
}

