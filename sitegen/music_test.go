package main

import (
	"testing"
)

func TestParseMusicItems(t *testing.T) {
	md := `<!-- MUSIC_LIST_START -->

### Chagrin

<div class="video-embed">
<iframe src="https://www.youtube.com/embed/LJYTnH2uOp8" title="Chagrin" frameborder="0" allowfullscreen></iframe>
</div>

### Playful Resilience

<div class="video-embed">
<iframe src="https://www.youtube.com/embed/vRcuFBIZR_g" title="Playful Resilience" frameborder="0" allowfullscreen></iframe>
</div>

### Moving On

<div class="video-embed">
<iframe src="https://www.youtube.com/embed/3vsQr9zeHCc" title="Moving On" frameborder="0" allowfullscreen></iframe>
</div>

<!-- MUSIC_LIST_END -->`

	items := parseMusicItems(md)
	if len(items) != 3 {
		t.Fatalf("expected 3 items, got %d", len(items))
	}
	if items[0].Title != "Chagrin" {
		t.Errorf("item[0].Title = %q", items[0].Title)
	}
	if items[0].VideoID != "LJYTnH2uOp8" {
		t.Errorf("item[0].VideoID = %q", items[0].VideoID)
	}
	if items[1].Title != "Playful Resilience" {
		t.Errorf("item[1].Title = %q", items[1].Title)
	}
	if items[1].VideoID != "vRcuFBIZR_g" {
		t.Errorf("item[1].VideoID = %q", items[1].VideoID)
	}
	if items[2].Title != "Moving On" {
		t.Errorf("item[2].Title = %q", items[2].Title)
	}
	if items[2].VideoID != "3vsQr9zeHCc" {
		t.Errorf("item[2].VideoID = %q", items[2].VideoID)
	}
}

func TestParseMusicItemsEmpty(t *testing.T) {
	if items := parseMusicItems(""); len(items) != 0 {
		t.Errorf("expected 0 items, got %d", len(items))
	}
	if items := parseMusicItems("no music here"); len(items) != 0 {
		t.Errorf("expected 0 items, got %d", len(items))
	}
}
