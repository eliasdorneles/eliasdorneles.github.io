package sitegen

import "core:fmt"
import "core:strings"
import "core:testing"

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
