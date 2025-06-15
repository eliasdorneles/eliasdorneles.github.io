package sitegen

import "core:fmt"
import "core:strings"
import "core:testing"
import "./vendor/cmark"

expect_strings_equal :: proc(t: ^testing.T, got, expected: string) {
    got_trimmed := strings.trim_right(got, "\n")
    expected_trimmed := strings.trim_right(expected, "\n")
    testing.expect_value(t, got_trimmed, expected_trimmed)
}

@(test)
test_generate_article_summary_with_marker :: proc(t: ^testing.T) {
    article := Article {
        md_content = "First paragraph\n\nSecond paragraph\n\nPELICAN_END_SUMMARY\n\nThird paragraph",
    }
    summary := generate_article_summary(&article)
    expected := "<p>First paragraph</p>\n<p>Second paragraph</p>\n"
    expect_strings_equal(t, summary, expected)
}

@(test)
test_generate_article_summary_without_marker :: proc(t: ^testing.T) {
    article := Article {
        md_content = "First paragraph\n\nSecond paragraph\n\nThird paragraph",
    }
    summary := generate_article_summary(&article)
    expected := "<p>First paragraph</p>\n"
    expect_strings_equal(t, summary, expected)
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
    expect_strings_equal(t, summary, expected)
}

@(test)
test_generate_article_summary_with_links :: proc(t: ^testing.T) {
    article := Article {
        md_content = "Check out [my site](https://example.com)\n\nSecond paragraph",
    }
    summary := generate_article_summary(&article)
    expected := "<p>Check out <a href=\"https://example.com\">my site</a></p>\n"
    expect_strings_equal(t, summary, expected)
}

@(test)
test_generate_article_summary_with_code :: proc(t: ^testing.T) {
    article := Article {
        md_content = "Here's some code:\n```python\nprint('hello')\n```\n\nSecond paragraph",
    }
    summary := generate_article_summary(&article)
    expected := "<p>Here's some code:</p>\n<pre><code class=\"language-python\">print('hello')\n</code></pre>\n"
    expect_strings_equal(t, summary, expected)
}

@(test)
test_clean_html_summary_keeps_first_image :: proc(t: ^testing.T) {
    html := "<p>Some text</p><img src='test.jpg' alt='test'><p>More text</p>"
    cleaned := clean_html_summary(html)
    expected := "<p>Some text</p><img src='test.jpg' alt='test'><p>More text</p>"
    expect_strings_equal(t, cleaned, expected)
}

@(test)
test_clean_html_summary_removes_extra_images :: proc(t: ^testing.T) {
    html := "<p>Start</p><img src='1.jpg'><img src='2.jpg'><img src='3.jpg'><p>End</p>"
    cleaned := clean_html_summary(html)
    expected := "<p>Start</p><img src='1.jpg'><p>End</p>"
    expect_strings_equal(t, cleaned, expected)
}

@(test)
test_clean_html_summary_preserves_other_tags :: proc(t: ^testing.T) {
    html := "<p>Some <strong>bold</strong> text</p><img src='test.jpg'><p>More <em>italic</em> text</p>"
    cleaned := clean_html_summary(html)
    expected := "<p>Some <strong>bold</strong> text</p><img src='test.jpg'><p>More <em>italic</em> text</p>"
    expect_strings_equal(t, cleaned, expected)
}

@(test)
test_generate_article_summary_with_image :: proc(t: ^testing.T) {
    article := Article {
        md_content = "First paragraph\n\n![Image](test.jpg)\n\nSecond paragraph",
    }
    summary := generate_article_summary(&article)
    expected := "<p>First paragraph</p>\n<p><img src=\"test.jpg\" alt=\"Image\" /></p>\n"
    expect_strings_equal(t, summary, expected)
}

@(test)
test_generate_article_summary_with_multiple_images :: proc(t: ^testing.T) {
    article := Article {
        md_content = "First paragraph\n\n![Image1](test1.jpg)\n\n![Image2](test2.jpg)\n\nSecond paragraph",
    }
    summary := generate_article_summary(&article)
    expected := "<p>First paragraph</p>\n<p><img src=\"test1.jpg\" alt=\"Image1\" /></p>\n"
    expect_strings_equal(t, summary, expected)
}

@(test)
test_generate_article_summary_with_image_and_marker :: proc(t: ^testing.T) {
    article := Article {
        md_content = "First paragraph\n\n![Image](test.jpg)\n\nPELICAN_END_SUMMARY\n\nSecond paragraph",
    }
    summary := generate_article_summary(&article)
    expected := "<p>First paragraph</p>\n<p><img src=\"test.jpg\" alt=\"Image\" /></p>\n"
    expect_strings_equal(t, summary, expected)
}

@(test)
test_render_article_content_tables :: proc(t: ^testing.T) {
    article := Article {
        md_content = "| Header 1 | Header 2 |\n|----------|----------|\n| Cell 1   | Cell 2   |\n| Cell 3   | Cell 4   |",
    }
    rendered := render_article_content(&article)
    expected := "<table>\n<thead>\n<tr>\n<th>Header 1</th>\n<th>Header 2</th>\n</tr>\n</thead>\n<tbody>\n<tr>\n<td>Cell 1</td>\n<td>Cell 2</td>\n</tr>\n<tr>\n<td>Cell 3</td>\n<td>Cell 4</td>\n</tr>\n</tbody>\n</table>\n"
    expect_strings_equal(t, rendered, expected)
}

@(test)
test_markdown_to_html_basic :: proc(t: ^testing.T) {
    input := "# Heading 1\n\nThis is a paragraph with **bold** and *italic* text."
    rendered := cmark.markdown_to_html_from_string(input, {.Unsafe})
    expected := "<h1>Heading 1</h1>\n<p>This is a paragraph with <strong>bold</strong> and <em>italic</em> text.</p>\n"
    expect_strings_equal(t, rendered, expected)
}

@(test)
test_markdown_to_html_tables :: proc(t: ^testing.T) {
    input := "| Header 1 | Header 2 |\n|----------|----------|\n| Cell 1   | Cell 2   |\n| Cell 3   | Cell 4   |"
    rendered := cmark.markdown_to_html_from_string(input, {.Unsafe})
    expected := "<table>\n<thead>\n<tr>\n<th>Header 1</th>\n<th>Header 2</th>\n</tr>\n</thead>\n<tbody>\n<tr>\n<td>Cell 1</td>\n<td>Cell 2</td>\n</tr>\n<tr>\n<td>Cell 3</td>\n<td>Cell 4</td>\n</tr>\n</tbody>\n</table>\n"
    expect_strings_equal(t, rendered, expected)
}

@(test)
test_markdown_to_html_code_blocks :: proc(t: ^testing.T) {
    input := "```python\nprint('hello')\n```"
    rendered := cmark.markdown_to_html_from_string(input, {.Unsafe})
    expected := "<pre><code class=\"language-python\">print('hello')\n</code></pre>\n"
    expect_strings_equal(t, rendered, expected)
}

@(test)
test_markdown_to_html_links :: proc(t: ^testing.T) {
    input := "[Link text](https://example.com)"
    rendered := cmark.markdown_to_html_from_string(input, {.Unsafe})
    expected := "<p><a href=\"https://example.com\">Link text</a></p>\n"
    expect_strings_equal(t, rendered, expected)
}

@(test)
test_markdown_to_html_lists :: proc(t: ^testing.T) {
    input := "- Item 1\n- Item 2\n  - Nested item\n- Item 3"
    rendered := cmark.markdown_to_html_from_string(input, {.Unsafe})
    expected := "<ul>\n<li>Item 1</li>\n<li>Item 2\n<ul>\n<li>Nested item</li>\n</ul>\n</li>\n<li>Item 3</li>\n</ul>\n"
    expect_strings_equal(t, rendered, expected)
}

@(test)
test_markdown_to_html_blockquotes :: proc(t: ^testing.T) {
    input := "> This is a blockquote\n> With multiple lines"
    rendered := cmark.markdown_to_html_from_string(input, {.Unsafe})
    expected := "<blockquote>\n<p>This is a blockquote\nWith multiple lines</p>\n</blockquote>\n"
    expect_strings_equal(t, rendered, expected)
}

@(test)
test_markdown_to_html_images :: proc(t: ^testing.T) {
    input := "![Alt text](image.jpg)"
    rendered := cmark.markdown_to_html_from_string(input, {.Unsafe})
    expected := "<p><img src=\"image.jpg\" alt=\"Alt text\" /></p>\n"
    expect_strings_equal(t, rendered, expected)
}

@(test)
test_markdown_to_html_escaped_chars :: proc(t: ^testing.T) {
    input := "\\* Not italic \\*"
    rendered := cmark.markdown_to_html_from_string(input, {.Unsafe})
    expected := "<p>* Not italic *</p>\n"
    expect_strings_equal(t, rendered, expected)
}

@(test)
test_markdown_to_html_horizontal_rule :: proc(t: ^testing.T) {
    input := "---"
    rendered := cmark.markdown_to_html_from_string(input, {.Unsafe})
    expected := "<hr />\n"
    expect_strings_equal(t, rendered, expected)
}

@(test)
test_markdown_to_html_inline_code :: proc(t: ^testing.T) {
    input := "This is `inline code` in a sentence"
    rendered := cmark.markdown_to_html_from_string(input, {.Unsafe})
    expected := "<p>This is <code>inline code</code> in a sentence</p>\n"
    expect_strings_equal(t, rendered, expected)
}
