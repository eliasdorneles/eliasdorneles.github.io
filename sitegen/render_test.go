package main

import (
	"os"
	"strings"
	"testing"
)

// Rendering real templates requires running from the repo root, where
// mytheme/templates lives.
func TestMain(m *testing.M) {
	if _, err := os.Stat(templatesDir); err != nil {
		if err := os.Chdir(".."); err != nil {
			panic(err)
		}
	}
	os.Exit(m.Run())
}

func testConfig() map[string]interface{} {
	return map[string]interface{}{
		"SITEURL":  "http://localhost:8000",
		"SITENAME": "Test Site",
		"MENUITEMS": []interface{}{
			map[string]interface{}{"title": "Blog", "url": ""},
		},
	}
}

func testArticle() *Article {
	return &Article{
		Title:     "My <em>fancy</em> article",
		Slug:      "my-article",
		Lang:      "en",
		Date:      "2023-05-01 20:00",
		Author:    "Elias",
		MDContent: "Hello **world**\n\n<div class=\"raw\">raw html</div>\n",
	}
}

func TestRenderArticleTemplate(t *testing.T) {
	article := testArticle()
	ctx := newRenderContext(testConfig())
	ctx["article"] = buildArticleContext(article)
	ctx["rel_source_path"] = "site/blog/my-article.md"

	rendered, err := renderTemplate("article.html", ctx)
	if err != nil {
		t.Fatal(err)
	}

	// raw HTML from markdown must NOT be escaped (autoescape off);
	// pins gonja's default so an upgrade flipping it gets caught
	if !strings.Contains(rendered, "<div class=\"raw\">raw html</div>") {
		t.Error("article content HTML was escaped or missing")
	}
	if !strings.Contains(rendered, "<strong>world</strong>") {
		t.Error("markdown-rendered content missing")
	}
	// date helpers wired through article_infos.html
	if !strings.Contains(rendered, "title=\"2023-05-01 20:00:00+02:00\"") {
		t.Error("date_iso missing")
	}
	if !strings.Contains(rendered, "01 May 2023") {
		t.Error("date_display missing")
	}
	// block inheritance: base.html header with SITENAME
	if !strings.Contains(rendered, "Test Site") {
		t.Error("base template SITENAME missing")
	}
	// {% if page is defined %} in base.html must not blow up without page
	if !strings.Contains(rendered, "<a href=\"http://localhost:8000/\">Blog</a>") {
		t.Error("menu items missing")
	}
}

func TestRenderArticleWithTranslations(t *testing.T) {
	article := testArticle()
	articleCtx := buildArticleContext(article)
	articleCtx["translations"] = []map[string]interface{}{
		{"lang": "pt-br", "url": "/2023/05/01/my-article-pt-br.html"},
	}
	ctx := newRenderContext(testConfig())
	ctx["article"] = articleCtx
	ctx["rel_source_path"] = "site/blog/my-article.md"

	rendered, err := renderTemplate("article.html", ctx)
	if err != nil {
		t.Fatal(err)
	}
	// lang_display_name() called as a context function from translations.html
	if !strings.Contains(rendered, "Português (Brasil)") {
		t.Error("translation display name missing")
	}
	if !strings.Contains(rendered, "/2023/05/01/my-article-pt-br.html") {
		t.Error("translation URL missing")
	}
}

func TestRenderBlogTemplate(t *testing.T) {
	article := testArticle()
	objectList := []interface{}{buildArticleContext(article)}
	ctx := newRenderContext(testConfig())
	ctx["articles_page"] = map[string]interface{}{"object_list": objectList}
	ctx["articles"] = objectList

	rendered, err := renderTemplate("blog.html", ctx)
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(rendered, "My <em>fancy</em> article") {
		t.Error("article title missing from blog listing")
	}
	if !strings.Contains(rendered, "01 May 2023") {
		t.Error("article date missing from blog listing")
	}
	// summary differs from content → "Continue reading" link shows
	if !strings.Contains(rendered, "Continue reading") {
		t.Error("continue reading link missing")
	}
}

func TestRenderHomeTemplate(t *testing.T) {
	article := testArticle()
	ctx := newRenderContext(testConfig())
	ctx["recent_articles"] = []interface{}{buildArticleContext(article)}

	rendered, err := renderTemplate("index.html", ctx)
	if err != nil {
		t.Fatal(err)
	}
	// hero + section cards make the home page, not a blog wall
	if !strings.Contains(rendered, "home-hero") {
		t.Error("home hero missing")
	}
	if !strings.Contains(rendered, "http://localhost:8000/blog/") {
		t.Error("link to blog listing missing")
	}
	// recent writing pulls the article through
	if !strings.Contains(rendered, "My <em>fancy</em> article") {
		t.Error("recent article missing from home page")
	}
}

func TestRenderPageTemplate(t *testing.T) {
	page := &Article{
		Title:     "About me",
		Slug:      "about",
		Lang:      "en",
		MDContent: "I am a *page*.\n",
	}
	ctx := newRenderContext(testConfig())
	ctx["page"] = buildPageContext(page)
	ctx["rel_source_path"] = "site/pages/about.md"

	rendered, err := renderTemplate("page.html", ctx)
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(rendered, "<h1 class=\"entry-title\">About me</h1>") {
		t.Error("page title missing")
	}
	if !strings.Contains(rendered, "<em>page</em>") {
		t.Error("page content missing")
	}
}

func TestNormalizeTemplateName(t *testing.T) {
	if got := normalizeTemplateName("", "article.html"); got != "article.html" {
		t.Errorf("got %q", got)
	}
	if got := normalizeTemplateName("noheader", "page.html"); got != "noheader.html" {
		t.Errorf("got %q", got)
	}
	if got := normalizeTemplateName("custom.html", "page.html"); got != "custom.html" {
		t.Errorf("got %q", got)
	}
}

func TestLangDisplayName(t *testing.T) {
	if langDisplayName("en") != "English" {
		t.Error("en")
	}
	if langDisplayName("pt-br") != "Português (Brasil)" {
		t.Error("pt-br")
	}
	if langDisplayName("fr") != "fr" {
		t.Error("unknown lang should pass through")
	}
}
