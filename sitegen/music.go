package main

import (
	"regexp"
	"strings"
)

// MusicItem holds the title and YouTube video ID of a music piece.
type MusicItem struct {
	Title   string
	VideoID string
}

var musicItemRe = regexp.MustCompile(`###\s+([^\n]+)\n[\s\S]*?youtube\.com/embed/([A-Za-z0-9_-]+)`)

// parseMusicItems extracts music items from the music page markdown content.
// It returns items in the order they appear in the source.
func parseMusicItems(mdContent string) []MusicItem {
	matches := musicItemRe.FindAllStringSubmatch(mdContent, -1)
	items := make([]MusicItem, 0, len(matches))
	for _, m := range matches {
		items = append(items, MusicItem{
			Title:   strings.TrimSpace(m[1]),
			VideoID: m[2],
		})
	}
	return items
}
