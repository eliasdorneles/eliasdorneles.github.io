package main

import (
	"testing"
)

func TestLoadArticleFromString(t *testing.T) {
	raw := "Title: My Article\nDate: 2023-05-01 20:00\nAuthor: Elias\nStatus: published\nSlug: custom-slug\nTemplate: noheader\n\nThe article content goes here.\n"
	article := Article{Slug: "from-filename"}
	if err := loadArticleFromString(&article, raw); err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if article.Title != "My Article" {
		t.Errorf("Title = %q", article.Title)
	}
	if article.Date != "2023-05-01 20:00" {
		t.Errorf("Date = %q", article.Date)
	}
	if article.Author != "Elias" {
		t.Errorf("Author = %q", article.Author)
	}
	if article.Status != "published" {
		t.Errorf("Status = %q", article.Status)
	}
	if article.Slug != "custom-slug" {
		t.Errorf("Slug = %q (frontmatter should override filename slug)", article.Slug)
	}
	if article.Template != "noheader" {
		t.Errorf("Template = %q", article.Template)
	}
	if article.Lang != "en" {
		t.Errorf("Lang = %q (should default to en)", article.Lang)
	}
	if article.MDContent != "The article content goes here.\n" {
		t.Errorf("MDContent = %q", article.MDContent)
	}
}

func TestLoadArticleFromStringWithLang(t *testing.T) {
	raw := "Title: Meu Artigo\nDate: 2023-05-01 20:00\nLang: pt-br\n\nO conteúdo do artigo vai aqui.\n"
	var article Article
	if err := loadArticleFromString(&article, raw); err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if article.Lang != "pt-br" {
		t.Errorf("Lang = %q", article.Lang)
	}
}

func TestLoadArticleFromStringMissingSeparator(t *testing.T) {
	raw := "Title: My Article\nDate: 2023-05-01 20:00\n"
	var article Article
	if err := loadArticleFromString(&article, raw); err == nil {
		t.Error("expected error for missing metadata separator")
	}
}

func TestLoadArticleFromStringMalformedLine(t *testing.T) {
	raw := "Title: My Article\nthis line has no colon\n\nSome content here, long enough.\n"
	var article Article
	if err := loadArticleFromString(&article, raw); err == nil {
		t.Error("expected error for metadata line without colon")
	}
}

func TestExtractYMD(t *testing.T) {
	year, month, day := extractYMD("2023-05-01 20:00")
	if year != "2023" || month != "05" || day != "01" {
		t.Errorf("got %s-%s-%s", year, month, day)
	}
}

func TestGetArticleFilename(t *testing.T) {
	en := &Article{Slug: "my-article", Lang: "en"}
	if got := getArticleFilename(en); got != "my-article.html" {
		t.Errorf("en filename = %q", got)
	}
	pt := &Article{Slug: "my-article", Lang: "pt-br"}
	if got := getArticleFilename(pt); got != "my-article-pt-br.html" {
		t.Errorf("pt-br filename = %q", got)
	}
}

func TestGetArticleURL(t *testing.T) {
	article := &Article{Slug: "so-i-m-releasing-a-single", Lang: "pt-br", Date: "2023-05-01 20:00"}
	expected := "/2023/05/01/so-i-m-releasing-a-single-pt-br.html"
	if got := getArticleURL(article); got != expected {
		t.Errorf("got %q, expected %q", got, expected)
	}
}

func TestGetPageURL(t *testing.T) {
	page := &Article{Slug: "about"}
	if got := getPageURL(page); got != "pages/about.html" {
		t.Errorf("got %q", got)
	}
}

func TestTranslations(t *testing.T) {
	en := Article{Slug: "my-article", Lang: "en", Date: "2023-05-01 20:00"}
	pt := Article{Slug: "my-article", Lang: "pt-br", Date: "2023-05-01 20:00"}
	other := Article{Slug: "other-article", Lang: "en", Date: "2023-06-01 10:00"}

	groups := groupArticlesBySlug([]Article{en, pt, other})
	if len(groups["my-article"]) != 2 {
		t.Fatalf("expected 2 articles in my-article group, got %d", len(groups["my-article"]))
	}
	if len(groups["other-article"]) != 1 {
		t.Fatalf("expected 1 article in other-article group, got %d", len(groups["other-article"]))
	}

	translations := createTranslations(&en, groups["my-article"])
	if len(translations) != 1 {
		t.Fatalf("expected 1 translation (self excluded), got %d", len(translations))
	}
	if translations[0]["lang"] != "pt-br" {
		t.Errorf("lang = %v", translations[0]["lang"])
	}
	if translations[0]["url"] != "/2023/05/01/my-article-pt-br.html" {
		t.Errorf("url = %v", translations[0]["url"])
	}
}

func TestSlugFromPath(t *testing.T) {
	if got := slugFromPath("site/blog/my-article.md"); got != "my-article" {
		t.Errorf("got %q", got)
	}
}

func TestDateFormatting(t *testing.T) {
	if got := dateISO("2023-05-01 20:00"); got != "2023-05-01 20:00:00+02:00" {
		t.Errorf("dateISO = %q", got)
	}
	if got := dateDisplay("2023-05-01 20:00"); got != "01 May 2023" {
		t.Errorf("dateDisplay = %q", got)
	}
	if got := dateDisplay("2012-11-07 16:58"); got != "07 Nov 2012" {
		t.Errorf("dateDisplay = %q", got)
	}
}
