package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strings"
)

func loadConfig(configFile string, local bool) (map[string]interface{}, error) {
	content, err := os.ReadFile(configFile)
	if err != nil {
		return nil, err
	}
	var config map[string]interface{}
	if err := json.Unmarshal(content, &config); err != nil {
		return nil, err
	}
	if local {
		config["SITEURL"] = "http://localhost:8000"
	}
	return config, nil
}

func writeFile(path, content string) error {
	return os.WriteFile(path, []byte(content), 0o644)
}

func main() {
	output := flag.String("output", "output_sitegen", "Output directory")
	configFile := flag.String("config-file", "config_sitegen.json", "Config file")
	local := flag.Bool("local", false, "Use localhost:8000 as SITEURL")
	flag.Parse()

	config, err := loadConfig(*configFile, *local)
	if err != nil {
		fmt.Fprintln(os.Stderr, "Error loading config file:", *configFile, "-", err)
		os.Exit(1)
	}

	countFilesWritten := 0

	// Process pages first
	pages, err := loadPages()
	if err != nil {
		fmt.Fprintln(os.Stderr, "error loading pages:", err)
		os.Exit(1)
	}
	pagesOutDir := filepath.Join(*output, "pages")
	if err := os.MkdirAll(pagesOutDir, 0o755); err != nil {
		fmt.Fprintln(os.Stderr, "Error attempting to create dir:", pagesOutDir)
	}
	for i := range pages {
		page := &pages[i]
		ctx := newRenderContext(config)
		ctx["page"] = buildPageContext(page)
		ctx["rel_source_path"] = fmt.Sprintf("site/pages/%s.md", page.Slug)

		rendered, err := renderTemplate(normalizeTemplateName(page.Template, "page.html"), ctx)
		if err != nil {
			fmt.Fprintln(os.Stderr, "Error rendering page:", page.Slug, "-", err)
			continue
		}
		targetPath := filepath.Join(pagesOutDir, page.Slug+".html")
		if err := writeFile(targetPath, rendered); err != nil {
			fmt.Fprintln(os.Stderr, "Error writing page:", targetPath)
			continue
		}
		countFilesWritten++
	}
	fmt.Printf("Rendered %d pages\n", countFilesWritten)

	// Now render the blog articles
	articles, err := loadArticles()
	if err != nil {
		fmt.Fprintln(os.Stderr, "error loading articles:", err)
		os.Exit(1)
	}
	sort.SliceStable(articles, func(i, j int) bool {
		return articles[i].Date > articles[j].Date
	})
	articleGroups := groupArticlesBySlug(articles)

	var objectList []interface{}
	for i := range articles {
		article := &articles[i]
		articleCtx := buildArticleContext(article)
		if translations := createTranslations(article, articleGroups[article.Slug]); translations != nil {
			articleCtx["translations"] = translations
		}

		ctx := newRenderContext(config)
		ctx["article"] = articleCtx
		ctx["rel_source_path"] = fmt.Sprintf("site/blog/%s.md", article.Slug)

		// Only add default language articles that are not drafts to the index page
		if article.Lang == defaultLang && article.Status != "draft" {
			objectList = append(objectList, articleCtx)
		}

		year, month, day := extractYMD(article.Date)
		outDirPath := filepath.Join(*output, year, month, day)
		if err := os.MkdirAll(outDirPath, 0o755); err != nil {
			fmt.Fprintln(os.Stderr, "Error attempting to create dir:", outDirPath)
		}

		rendered, err := renderTemplate(normalizeTemplateName(article.Template, "article.html"), ctx)
		if err != nil {
			fmt.Fprintln(os.Stderr, "error rendering article:", article.Slug, "-", err)
			continue
		}
		// Replace {static} with relative path for articles
		rendered = strings.ReplaceAll(rendered, "{static}", "../../../")
		targetPath := filepath.Join(outDirPath, getArticleFilename(article))
		if err := writeFile(targetPath, rendered); err != nil {
			fmt.Fprintln(os.Stderr, "Error writing file:", targetPath)
			continue
		}
		countFilesWritten++
	}

	// Generate index page
	indexCtx := newRenderContext(config)
	indexCtx["articles_page"] = map[string]interface{}{"object_list": objectList}
	indexCtx["articles"] = objectList // for backwards compatibility

	rendered, err := renderTemplate("index.html", indexCtx)
	if err != nil {
		fmt.Fprintln(os.Stderr, "error rendering index template:", err)
	} else {
		// Remove {static} for index page
		rendered = strings.ReplaceAll(rendered, "{static}", "")
		rendered = strings.ReplaceAll(rendered, "%7Bstatic%7D", "")
		targetPath := filepath.Join(*output, "index.html")
		if err := writeFile(targetPath, rendered); err != nil {
			fmt.Fprintln(os.Stderr, "Error writing index file:", targetPath)
		} else {
			countFilesWritten++
		}
	}

	fmt.Printf("\nWrote %d files!\n\n", countFilesWritten)

	fmt.Println("Copying assets...")
	if err := copyAssets(*output); err != nil {
		fmt.Fprintln(os.Stderr, "Error copying assets:", err)
		os.Exit(1)
	}

	fmt.Println("\nAll done!")
}
