package main

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"time"
)

const (
	blogArticlesGlob = "site/blog/*.md"
	pagesGlob        = "site/pages/*.md"

	defaultLang = "en"
)

type Article struct {
	Title     string
	Date      string // raw frontmatter format: "2006-01-02 15:04"
	Filepath  string
	Slug      string
	Lang      string
	MDContent string
	Author    string
	Template  string
	Status    string
}

func extractYMD(date string) (year, month, day string) {
	return date[:4], date[5:7], date[8:10]
}

// dateISO reproduces the old engine's isoformat() output: the frontmatter
// date string with a hardcoded seconds + timezone suffix.
func dateISO(date string) string {
	return date + ":00+02:00"
}

// dateDisplay reproduces strftime("%d %b %Y") under en_US locale.
// Only the date part is used; the time may or may not include seconds.
func dateDisplay(date string) string {
	if len(date) < 10 {
		return date
	}
	parsed, err := time.Parse("2006-01-02", date[:10])
	if err != nil {
		return date
	}
	return parsed.Format("02 Jan 2006")
}

// loadArticleFromString parses the frontmatter (plain "Key: value" lines,
// terminated by a blank line) and stores the rest as markdown content.
func loadArticleFromString(article *Article, rawContent string) error {
	for index := 0; index < len(rawContent); {
		eol := strings.IndexByte(rawContent[index:], '\n')
		if eol == -1 {
			break
		}
		line := rawContent[index : index+eol]
		index += eol + 1

		if line == "" {
			// blank line means the end of the metadata section
			if len(rawContent) < index+10 {
				return fmt.Errorf("article missing metadata or is too short: %s", article.Filepath)
			}
			article.MDContent = rawContent[index:]
			if article.Lang == "" {
				article.Lang = defaultLang
			}
			return nil
		}

		key, value, found := strings.Cut(line, ":")
		if !found {
			return fmt.Errorf("malformed metadata line %q in %s", line, article.Filepath)
		}
		value = strings.TrimSpace(value)
		switch key {
		case "Title":
			article.Title = value
		case "Date":
			article.Date = value
		case "Slug":
			article.Slug = value
		case "Lang":
			article.Lang = value
		case "Author":
			article.Author = value
		case "Template":
			article.Template = value
		case "Status":
			article.Status = value
		}
	}
	return fmt.Errorf("article is mal-formed, missing sep between metadata and content: %s", article.Filepath)
}

func slugFromPath(path string) string {
	filename := filepath.Base(path)
	return strings.TrimSuffix(filename, ".md")
}

func loadArticlesFromGlob(glob string) ([]Article, error) {
	pathList, err := filepath.Glob(glob)
	if err != nil {
		return nil, err
	}
	var articles []Article
	for _, path := range pathList {
		content, err := os.ReadFile(path)
		if err != nil {
			return nil, err
		}
		article := Article{Filepath: path, Slug: slugFromPath(path)}
		if err := loadArticleFromString(&article, string(content)); err != nil {
			return nil, err
		}
		articles = append(articles, article)
	}
	return articles, nil
}

func loadArticles() ([]Article, error) {
	return loadArticlesFromGlob(blogArticlesGlob)
}

func loadPages() ([]Article, error) {
	return loadArticlesFromGlob(pagesGlob)
}

func getPageURL(page *Article) string {
	return fmt.Sprintf("pages/%s.html", page.Slug)
}

// getArticleFilename returns the filename for an article based on its slug and language
func getArticleFilename(article *Article) string {
	if article.Lang == defaultLang {
		return fmt.Sprintf("%s.html", article.Slug)
	}
	return fmt.Sprintf("%s-%s.html", article.Slug, article.Lang)
}

// getArticleURL returns the URL for an article based on its date, slug and language
func getArticleURL(article *Article) string {
	year, month, day := extractYMD(article.Date)
	return fmt.Sprintf("/%s/%s/%s/%s", year, month, day, getArticleFilename(article))
}

// groupArticlesBySlug groups articles by slug to find translations
func groupArticlesBySlug(articles []Article) map[string][]Article {
	groups := make(map[string][]Article)
	for _, article := range articles {
		groups[article.Slug] = append(groups[article.Slug], article)
	}
	return groups
}

// createTranslations builds the translations list for an article
func createTranslations(article *Article, translations []Article) []map[string]interface{} {
	var result []map[string]interface{}
	for i := range translations {
		translation := &translations[i]
		if translation.Lang != article.Lang {
			result = append(result, map[string]interface{}{
				"lang": translation.Lang,
				"url":  getArticleURL(translation),
			})
		}
	}
	return result
}
