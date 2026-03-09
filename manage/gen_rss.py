#!/usr/bin/env python3
"""
Generate RSS feed from blog posts.

Reads site/blog/*.md, filters published English posts,
extracts content from rendered HTML, writes feed.xml to output dir.
"""

import argparse
import json
import xml.etree.ElementTree as ET
from datetime import datetime, timezone
from email.utils import format_datetime
from pathlib import Path
from urllib.parse import urljoin

from bs4 import BeautifulSoup

BASE_DIR = Path(__file__).resolve().parent.parent
BLOG_DIR = BASE_DIR / "site" / "blog"
CONFIG_FILE = BASE_DIR / "config_sitegen.json"


def parse_frontmatter(content: str) -> tuple[dict, str]:
    lines = content.split("\n")
    metadata = {}
    body_start = 0

    for i, line in enumerate(lines):
        stripped = line.strip()
        if not stripped:
            body_start = i + 1
            break
        if ":" in stripped:
            key, _, value = stripped.partition(":")
            metadata[key.strip().lower()] = value.strip()
            body_start = i + 1

    body = "\n".join(lines[body_start:])
    return metadata, body


def parse_date(date_str: str) -> datetime:
    for fmt in ("%Y-%m-%d %H:%M:%S", "%Y-%m-%d %H:%M", "%Y-%m-%d"):
        try:
            return datetime.strptime(date_str, fmt).replace(tzinfo=timezone.utc)
        except ValueError:
            continue
    raise ValueError(f"Cannot parse date: {date_str!r}")


def get_output_path(md_file: Path, meta: dict, output_dir: Path) -> Path | None:
    date_str = meta.get("date", "")
    if not date_str:
        return None
    try:
        dt = parse_date(date_str)
    except ValueError:
        return None

    date_path = dt.strftime("%Y/%m/%d")
    slug = md_file.stem  # filename without .md
    return output_dir / date_path / f"{slug}.html"


def extract_content(html_file: Path, article_url: str) -> str:
    soup = BeautifulSoup(html_file.read_text(encoding="utf-8"), "html.parser")
    entry_div = soup.find("div", class_="entry-content")
    if not entry_div:
        return ""

    # Remove the post-info footer (metadata block)
    post_info = entry_div.find("footer", class_="post-info")
    if post_info:
        post_info.decompose()

    # Remove taglist div if present inside entry-content
    taglist = entry_div.find("div", class_="taglist")
    if taglist:
        taglist.decompose()

    # Resolve all relative URLs (src and href) to absolute using the article URL as base
    for tag, attr in [("img", "src"), ("a", "href"), ("source", "src")]:
        for el in entry_div.find_all(tag, **{attr: True}):
            el[attr] = urljoin(article_url, el[attr])

    return entry_div.decode_contents().strip()


def load_posts(output_dir: Path) -> list[dict]:
    with open(CONFIG_FILE) as f:
        config = json.load(f)
    siteurl = config["SITEURL"]
    sitename = config["SITENAME"]

    posts = []
    for md_file in sorted(BLOG_DIR.glob("*.md")):
        content = md_file.read_text(encoding="utf-8")
        meta, _ = parse_frontmatter(content)

        if meta.get("status", "").lower() != "published":
            continue

        lang = meta.get("lang", "").lower()
        # Exclude non-English translations (e.g. pt-br)
        if lang and lang != "en":
            continue

        date_str = meta.get("date", "")
        if not date_str:
            continue

        try:
            dt = parse_date(date_str)
        except ValueError:
            continue

        html_file = get_output_path(md_file, meta, output_dir)
        if html_file is None or not html_file.exists():
            continue

        date_path = dt.strftime("%Y/%m/%d")
        slug = md_file.stem
        url = f"{siteurl}/{date_path}/{slug}.html"

        posts.append(
            {
                "title": meta.get("title", slug),
                "url": url,
                "date": dt,
                "author": meta.get("author", ""),
                "html_file": html_file,
                "siteurl": siteurl,
            }
        )

    posts.sort(key=lambda p: p["date"], reverse=True)
    return posts[:20], sitename, siteurl


def build_rss(posts: list[dict], sitename: str, siteurl: str) -> ET.Element:
    ET.register_namespace("content", "http://purl.org/rss/1.0/modules/content/")
    ET.register_namespace("atom", "http://www.w3.org/2005/Atom")

    rss = ET.Element("rss", version="2.0", attrib={
        "xmlns:content": "http://purl.org/rss/1.0/modules/content/",
        "xmlns:atom": "http://www.w3.org/2005/Atom",
    })

    channel = ET.SubElement(rss, "channel")

    ET.SubElement(channel, "title").text = sitename
    ET.SubElement(channel, "link").text = siteurl
    ET.SubElement(channel, "description").text = f"{sitename}'s blog"
    ET.SubElement(channel, "language").text = "en"
    ET.SubElement(channel, "atom:link", attrib={
        "href": f"{siteurl}/feed.xml",
        "rel": "self",
        "type": "application/rss+xml",
    })

    if posts:
        ET.SubElement(channel, "lastBuildDate").text = format_datetime(posts[0]["date"])

    for post in posts:
        item = ET.SubElement(channel, "item")
        ET.SubElement(item, "title").text = post["title"]
        ET.SubElement(item, "link").text = post["url"]
        ET.SubElement(item, "guid", isPermaLink="true").text = post["url"]
        ET.SubElement(item, "pubDate").text = format_datetime(post["date"])
        if post["author"]:
            ET.SubElement(item, "author").text = post["author"]

        content_html = extract_content(post["html_file"], post["url"])
        if content_html:
            encoded = ET.SubElement(item, "content:encoded")
            encoded.text = content_html

    return rss


def indent_xml(elem: ET.Element, level: int = 0) -> None:
    indent = "\n" + "  " * level
    if len(elem):
        if not elem.text or not elem.text.strip():
            elem.text = indent + "  "
        if not elem.tail or not elem.tail.strip():
            elem.tail = indent
        for child in elem:
            indent_xml(child, level + 1)
        if not child.tail or not child.tail.strip():
            child.tail = indent
    else:
        if level and (not elem.tail or not elem.tail.strip()):
            elem.tail = indent
    if not level:
        elem.tail = "\n"


def main():
    parser = argparse.ArgumentParser(description="Generate RSS feed for the blog")
    parser.add_argument(
        "--output-dir",
        default="output",
        help="Output directory (default: output)",
    )
    args = parser.parse_args()

    output_dir = Path(args.output_dir).resolve()
    if not output_dir.exists():
        print(f"Error: output directory does not exist: {output_dir}")
        raise SystemExit(1)

    posts, sitename, siteurl = load_posts(output_dir)
    print(f"Found {len(posts)} published English posts")

    rss = build_rss(posts, sitename, siteurl)
    indent_xml(rss)

    tree = ET.ElementTree(rss)
    feed_path = output_dir / "feed.xml"
    with open(feed_path, "w", encoding="utf-8") as f:
        f.write('<?xml version="1.0" encoding="UTF-8"?>\n')
        tree.write(f, encoding="unicode", xml_declaration=False)

    print(f"Written: {feed_path}")


if __name__ == "__main__":
    main()
