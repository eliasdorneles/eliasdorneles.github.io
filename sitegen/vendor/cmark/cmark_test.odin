package vendor_cmark_gfm

import "core:strings"
import "core:testing"

expect_strings_equal :: proc(t: ^testing.T, got, expected: string) {
    got_trimmed := strings.trim_right(got, "\n")
    expected_trimmed := strings.trim_right(expected, "\n")
    testing.expect_value(t, got_trimmed, expected_trimmed)
}

@(test)
test_markdown_to_html_basic :: proc(t: ^testing.T) {
    input := "# Heading 1\n\nThis is a paragraph with **bold** and *italic* text."
    rendered := markdown_to_html_from_string(input, {.Unsafe})
    defer delete(rendered)
    expected := "<h1>Heading 1</h1>\n<p>This is a paragraph with <strong>bold</strong> and <em>italic</em> text.</p>\n"
    expect_strings_equal(t, rendered, expected)
}

@(test)
test_markdown_to_html_tables :: proc(t: ^testing.T) {
    input := "| Header 1 | Header 2 |\n|----------|----------|\n| Cell 1   | Cell 2   |\n| Cell 3   | Cell 4   |"
    rendered := markdown_to_html_from_string(input, {.Unsafe})
    defer delete(rendered)
    expected := "<table>\n<thead>\n<tr>\n<th>Header 1</th>\n<th>Header 2</th>\n</tr>\n</thead>\n<tbody>\n<tr>\n<td>Cell 1</td>\n<td>Cell 2</td>\n</tr>\n<tr>\n<td>Cell 3</td>\n<td>Cell 4</td>\n</tr>\n</tbody>\n</table>\n"
    expect_strings_equal(t, rendered, expected)
}

@(test)
test_markdown_to_html_code_blocks :: proc(t: ^testing.T) {
    input := "```python\nprint('hello')\n```"
    rendered := markdown_to_html_from_string(input, {.Unsafe})
    defer delete(rendered)
    expected := "<pre><code class=\"language-python\">print('hello')\n</code></pre>\n"
    expect_strings_equal(t, rendered, expected)
}

@(test)
test_markdown_to_html_links :: proc(t: ^testing.T) {
    input := "[Link text](https://example.com)"
    rendered := markdown_to_html_from_string(input, {.Unsafe})
    defer delete(rendered)
    expected := "<p><a href=\"https://example.com\">Link text</a></p>\n"
    expect_strings_equal(t, rendered, expected)
}

@(test)
test_markdown_to_html_lists :: proc(t: ^testing.T) {
    input := "- Item 1\n- Item 2\n  - Nested item\n- Item 3"
    rendered := markdown_to_html_from_string(input, {.Unsafe})
    defer delete(rendered)
    expected := "<ul>\n<li>Item 1</li>\n<li>Item 2\n<ul>\n<li>Nested item</li>\n</ul>\n</li>\n<li>Item 3</li>\n</ul>\n"
    expect_strings_equal(t, rendered, expected)
}

@(test)
test_markdown_to_html_blockquotes :: proc(t: ^testing.T) {
    input := "> This is a blockquote\n> With multiple lines"
    rendered := markdown_to_html_from_string(input, {.Unsafe})
    defer delete(rendered)
    expected := "<blockquote>\n<p>This is a blockquote\nWith multiple lines</p>\n</blockquote>\n"
    expect_strings_equal(t, rendered, expected)
}

@(test)
test_markdown_to_html_images :: proc(t: ^testing.T) {
    input := "![Alt text](image.jpg)"
    rendered := markdown_to_html_from_string(input, {.Unsafe})
    defer delete(rendered)
    expected := "<p><img src=\"image.jpg\" alt=\"Alt text\" /></p>\n"
    expect_strings_equal(t, rendered, expected)
}

@(test)
test_markdown_to_html_escaped_chars :: proc(t: ^testing.T) {
    input := "\\* Not italic \\*"
    rendered := markdown_to_html_from_string(input, {.Unsafe})
    defer delete(rendered)
    expected := "<p>* Not italic *</p>\n"
    expect_strings_equal(t, rendered, expected)
}

@(test)
test_markdown_to_html_horizontal_rule :: proc(t: ^testing.T) {
    input := "---"
    rendered := markdown_to_html_from_string(input, {.Unsafe})
    defer delete(rendered)
    expected := "<hr />\n"
    expect_strings_equal(t, rendered, expected)
}

@(test)
test_markdown_to_html_inline_code :: proc(t: ^testing.T) {
    input := "This is `inline code` in a sentence"
    rendered := markdown_to_html_from_string(input, {.Unsafe})
    defer delete(rendered)
    expected := "<p>This is <code>inline code</code> in a sentence</p>\n"
    expect_strings_equal(t, rendered, expected)
}
