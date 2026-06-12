package main

import (
	"fmt"
	"strings"

	"github.com/nikolalohinski/gonja/v2"
	"github.com/nikolalohinski/gonja/v2/config"
	"github.com/nikolalohinski/gonja/v2/exec"
	"github.com/nikolalohinski/gonja/v2/loaders"
)

const templatesDir = "mytheme/templates"

var templateCache = map[string]*exec.Template{}

func getTemplate(name string) (*exec.Template, error) {
	if template, ok := templateCache[name]; ok {
		return template, nil
	}
	cfg := config.New()
	cfg.KeepTrailingNewline = true
	loader, err := loaders.NewFileSystemLoader(templatesDir)
	if err != nil {
		return nil, err
	}
	template, err := exec.NewTemplate(name, cfg, loader, gonja.DefaultEnvironment)
	if err != nil {
		return nil, fmt.Errorf("loading template %s: %w", name, err)
	}
	templateCache[name] = template
	return template, nil
}

func renderTemplate(name string, data map[string]interface{}) (string, error) {
	template, err := getTemplate(name)
	if err != nil {
		return "", err
	}
	rendered, err := template.ExecuteToString(exec.NewContext(data))
	if err != nil {
		return "", fmt.Errorf("rendering template %s: %w", name, err)
	}
	return rendered, nil
}

func langDisplayName(lang string) string {
	switch lang {
	case "en":
		return "English"
	case "pt-br":
		return "Português (Brasil)"
	}
	return lang
}

// normalizeTemplateName resolves the frontmatter Template value, appending
// ".html" if missing, and falls back to the given default.
func normalizeTemplateName(template, defaultName string) string {
	if template == "" {
		return defaultName
	}
	if !strings.HasSuffix(template, ".html") {
		return template + ".html"
	}
	return template
}

// newRenderContext builds a fresh per-render context from the site config.
func newRenderContext(config map[string]interface{}) map[string]interface{} {
	ctx := make(map[string]interface{}, len(config)+3)
	for key, value := range config {
		ctx[key] = value
	}
	ctx["lang_display_name"] = langDisplayName
	return ctx
}

func buildArticleContext(article *Article) map[string]interface{} {
	return map[string]interface{}{
		"title":        article.Title,
		"slug":         article.Slug,
		"date":         dateISO(article.Date),
		"date_iso":     dateISO(article.Date),
		"date_display": dateDisplay(article.Date),
		"author":       article.Author,
		"url":          getArticleURL(article),
		"content":      renderArticleContent(article),
		"_summary":     generateArticleSummary(article, summaryMaxLength),
	}
}

func buildPageContext(page *Article) map[string]interface{} {
	return map[string]interface{}{
		"title":   page.Title,
		"slug":    page.Slug,
		"date":    page.Date,
		"author":  page.Author,
		"url":     getPageURL(page),
		"content": renderArticleContent(page),
	}
}
