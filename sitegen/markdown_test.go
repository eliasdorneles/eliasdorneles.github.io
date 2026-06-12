package main

import (
	"strings"
	"testing"
)

func expectStringsEqual(t *testing.T, got, expected string) {
	t.Helper()
	gotTrimmed := strings.TrimRight(got, "\n")
	expectedTrimmed := strings.TrimRight(expected, "\n")
	if gotTrimmed != expectedTrimmed {
		t.Errorf("got:\n%q\nexpected:\n%q", gotTrimmed, expectedTrimmed)
	}
}

func TestGenerateArticleSummary(t *testing.T) {
	tests := []struct {
		name      string
		mdContent string
		expected  string
	}{
		{
			name:      "with marker",
			mdContent: "First paragraph\n\nSecond paragraph\n\nPELICAN_END_SUMMARY\n\nThird paragraph",
			expected:  "<p>First paragraph</p>\n<p>Second paragraph</p>\n",
		},
		{
			name:      "without marker",
			mdContent: "First paragraph\n\nSecond paragraph\n\nThird paragraph",
			expected:  "<p>First paragraph</p>\n",
		},
		{
			name:      "empty",
			mdContent: "",
			expected:  "",
		},
		{
			name:      "markdown formatting",
			mdContent: "**Bold** and *italic* text\n\nSecond paragraph",
			expected:  "<p><strong>Bold</strong> and <em>italic</em> text</p>\n",
		},
		{
			name:      "with links",
			mdContent: "Check out [my site](https://example.com)\n\nSecond paragraph",
			expected:  "<p>Check out <a href=\"https://example.com\">my site</a></p>\n",
		},
		{
			name:      "with code",
			mdContent: "Here's some code:\n```python\nprint('hello')\n```\n\nSecond paragraph",
			expected:  "<p>Here's some code:</p>\n<pre><code class=\"language-python\">print('hello')\n</code></pre>\n",
		},
		{
			name:      "with image",
			mdContent: "First paragraph\n\n![Image](test.jpg)\n\nSecond paragraph",
			expected:  "<p>First paragraph</p>\n<p><img src=\"test.jpg\" alt=\"Image\" /></p>\n",
		},
		{
			name:      "with multiple images",
			mdContent: "First paragraph\n\n![Image1](test1.jpg)\n\n![Image2](test2.jpg)\n\nSecond paragraph",
			expected:  "<p>First paragraph</p>\n<p><img src=\"test1.jpg\" alt=\"Image1\" /></p>\n",
		},
		{
			name:      "with image and marker",
			mdContent: "First paragraph\n\n![Image](test.jpg)\n\nPELICAN_END_SUMMARY\n\nSecond paragraph",
			expected:  "<p>First paragraph</p>\n<p><img src=\"test.jpg\" alt=\"Image\" /></p>\n",
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			article := &Article{MDContent: tt.mdContent}
			expectStringsEqual(t, generateArticleSummary(article, summaryMaxLength), tt.expected)
		})
	}
}

func TestCleanHTMLSummary(t *testing.T) {
	tests := []struct {
		name     string
		html     string
		expected string
	}{
		{
			name:     "keeps first image",
			html:     "<p>Some text</p><img src='test.jpg' alt='test'><p>More text</p>",
			expected: "<p>Some text</p><img src='test.jpg' alt='test'><p>More text</p>",
		},
		{
			name:     "removes extra images",
			html:     "<p>Start</p><img src='1.jpg'><img src='2.jpg'><img src='3.jpg'><p>End</p>",
			expected: "<p>Start</p><img src='1.jpg'><p>End</p>",
		},
		{
			name:     "preserves other tags",
			html:     "<p>Some <strong>bold</strong> text</p><img src='test.jpg'><p>More <em>italic</em> text</p>",
			expected: "<p>Some <strong>bold</strong> text</p><img src='test.jpg'><p>More <em>italic</em> text</p>",
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			expectStringsEqual(t, cleanHTMLSummary(tt.html), tt.expected)
		})
	}
}

func TestRenderArticleContentTables(t *testing.T) {
	article := &Article{
		MDContent: "| Header 1 | Header 2 |\n|----------|----------|\n| Cell 1   | Cell 2   |\n| Cell 3   | Cell 4   |",
	}
	expected := "<table>\n<thead>\n<tr>\n<th>Header 1</th>\n<th>Header 2</th>\n</tr>\n</thead>\n<tbody>\n<tr>\n<td>Cell 1</td>\n<td>Cell 2</td>\n</tr>\n<tr>\n<td>Cell 3</td>\n<td>Cell 4</td>\n</tr>\n</tbody>\n</table>\n"
	expectStringsEqual(t, renderArticleContent(article), expected)
}

func TestRenderArticleContentStaticReplacement(t *testing.T) {
	article := &Article{MDContent: "![pic]({static}/images/pic.jpg)"}
	expected := "<p><img src=\"../../..//images/pic.jpg\" alt=\"pic\" /></p>\n"
	expectStringsEqual(t, renderArticleContent(article), expected)
}
