package main

import (
	"bytes"
	"strings"

	"github.com/yuin/goldmark"
	"github.com/yuin/goldmark/extension"
	"github.com/yuin/goldmark/renderer/html"
)

const summaryMaxLength = 1 // number of paragraphs to include in summary

// Same setup as the old cmark-gfm wrapper: tables + strikethrough extensions,
// raw HTML allowed, XHTML-style self-closing tags (<img ... />, <hr />).
var markdown = goldmark.New(
	goldmark.WithExtensions(extension.Table, extension.Strikethrough),
	goldmark.WithRendererOptions(html.WithUnsafe(), html.WithXHTML()),
)

func markdownToHTML(mdContent string) string {
	var buf bytes.Buffer
	if err := markdown.Convert([]byte(mdContent), &buf); err != nil {
		panic(err)
	}
	return buf.String()
}

func renderArticleContent(article *Article) string {
	mdContent := strings.ReplaceAll(article.MDContent, "{static}", "../../../")
	return markdownToHTML(mdContent)
}

// cleanHTMLSummary keeps only the first <img> tag, drops the others, and
// strips a trailing empty <p></p> left behind by the removal.
func cleanHTMLSummary(htmlContent string) string {
	var builder, tagBuffer strings.Builder
	inTag := false
	seenImage := false

	for _, char := range htmlContent {
		if char == '<' {
			inTag = true
			tagBuffer.WriteRune(char)
			continue
		}
		if char == '>' {
			inTag = false
			tag := tagBuffer.String()
			if strings.HasPrefix(tag, "<img") {
				if !seenImage {
					builder.WriteString(tag)
					builder.WriteRune('>')
					seenImage = true
				}
			} else {
				builder.WriteString(tag)
				builder.WriteRune('>')
			}
			tagBuffer.Reset()
			continue
		}
		if inTag {
			tagBuffer.WriteRune(char)
		} else {
			builder.WriteRune(char)
		}
	}

	result := strings.TrimSpace(builder.String())
	result = strings.TrimSuffix(result, "<p></p>")
	return result
}

func generateArticleSummary(article *Article, maxParagraphs int) string {
	// First try to find PELICAN_END_SUMMARY marker
	if endMarker := strings.Index(article.MDContent, "PELICAN_END_SUMMARY"); endMarker != -1 {
		return cleanHTMLSummary(markdownToHTML(article.MDContent[:endMarker]))
	}

	// Otherwise take first maxParagraphs paragraphs and first image
	paragraphs := strings.Split(article.MDContent, "\n\n")

	firstImageIdx := -1
	for idx, paragraph := range paragraphs {
		if strings.HasPrefix(strings.TrimSpace(paragraph), "![") {
			firstImageIdx = idx
			break
		}
	}

	summaryParagraphs := paragraphs[:min(maxParagraphs, len(paragraphs))]
	if firstImageIdx != -1 && firstImageIdx >= maxParagraphs {
		summaryParagraphs = append(summaryParagraphs[:len(summaryParagraphs):len(summaryParagraphs)], paragraphs[firstImageIdx])
	}

	summaryMD := strings.Join(summaryParagraphs, "\n\n")
	return cleanHTMLSummary(markdownToHTML(summaryMD))
}
