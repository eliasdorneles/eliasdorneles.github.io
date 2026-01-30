#!/usr/bin/env python3
"""
Blog Post Editor - Flask Backend

A local WordPress-like blog editor with drag-and-drop images,
live markdown preview, and auto-save.
"""

import io
import os
import re
from datetime import datetime
from pathlib import Path

from flask import Flask, jsonify, request, send_file, send_from_directory
from PIL import Image

# Configuration
BASE_DIR = Path(__file__).resolve().parent.parent.parent
BLOG_DIR = BASE_DIR / "site" / "blog"
IMAGES_DIR = BASE_DIR / "site" / "images"
EDITOR_DIR = Path(__file__).resolve().parent

ALLOWED_IMAGE_EXTENSIONS = {"png", "jpg", "jpeg", "gif", "webp", "svg"}

app = Flask(__name__)


def title_to_slug(title: str) -> str:
    """Convert a title to a URL-friendly slug (matches site_manage.odin logic)."""
    # Normalize unicode and handle accented characters
    accent_map = {
        "á": "a", "à": "a", "ã": "a", "â": "a",
        "Á": "a", "À": "a", "Ã": "a", "Â": "a",
        "é": "e", "ê": "e", "É": "e", "Ê": "e",
        "í": "i", "Í": "i",
        "ó": "o", "õ": "o", "ô": "o",
        "Ó": "o", "Õ": "o", "Ô": "o",
        "ú": "u", "Ú": "u",
        "ç": "c", "Ç": "c",
    }

    result = []
    last_was_space = True

    for char in title:
        if char.isalnum() and ord(char) < 128:
            result.append(char.lower())
            last_was_space = False
        elif char in (" ", "\t"):
            if not last_was_space:
                result.append("-")
                last_was_space = True
        elif char in accent_map:
            result.append(accent_map[char])
            last_was_space = False
        # Skip other special characters

    slug = "".join(result)
    return slug.rstrip("-")


def parse_frontmatter(content: str) -> tuple[dict, str]:
    """Parse frontmatter from post content."""
    lines = content.split("\n")
    metadata = {}
    body_start = 0

    for i, line in enumerate(lines):
        line = line.strip()
        if not line:
            body_start = i + 1
            break
        if ":" in line:
            key, _, value = line.partition(":")
            metadata[key.strip().lower()] = value.strip()
            body_start = i + 1

    body = "\n".join(lines[body_start:])
    return metadata, body


def build_frontmatter(metadata: dict) -> str:
    """Build frontmatter string from metadata dict."""
    lines = []
    # Preserve order: Title, Date, Author, Status
    order = ["title", "date", "author", "status"]
    for key in order:
        if key in metadata and metadata[key]:
            # Capitalize key for output
            lines.append(f"{key.capitalize()}: {metadata[key]}")
    return "\n".join(lines)


def get_post_list() -> list[dict]:
    """Get list of all blog posts with metadata, sorted by date (most recent first)."""
    posts = []
    for filepath in BLOG_DIR.glob("*.md"):
        try:
            content = filepath.read_text(encoding="utf-8")
            metadata, _ = parse_frontmatter(content)
            posts.append({
                "filename": filepath.name,
                "title": metadata.get("title", filepath.stem),
                "date": metadata.get("date", ""),
                "status": metadata.get("status", "published"),
            })
        except Exception as e:
            print(f"Error reading {filepath}: {e}")
    # Sort by date (YYYY-MM-DD HH:MM format), most recent first
    # Posts without dates go to the end
    posts.sort(key=lambda p: p["date"] or "", reverse=True)
    return posts


def sanitize_filename(filename: str) -> str:
    """Sanitize a filename to be safe for the filesystem."""
    # Remove path components
    filename = os.path.basename(filename)
    # Replace spaces with underscores
    filename = filename.replace(" ", "_")
    # Remove any characters that aren't alphanumeric, underscore, hyphen, or dot
    filename = re.sub(r"[^\w\-.]", "", filename)
    return filename


# Image processing settings
MAX_IMAGE_WIDTH = 1200
JPEG_QUALITY = 85
PNG_COMPRESS_LEVEL = 6


def process_image(file_data: bytes, filename: str) -> tuple[bytes, str]:
    """
    Process an uploaded image: resize if too large, compress.
    Returns (processed_bytes, final_filename).

    - Resizes images wider than MAX_IMAGE_WIDTH pixels
    - Compresses JPEGs to JPEG_QUALITY
    - Optimizes PNGs
    - Leaves SVGs and GIFs untouched
    """
    ext = filename.rsplit(".", 1)[-1].lower() if "." in filename else ""

    # Don't process SVGs (vector) or GIFs (might be animated)
    if ext in ("svg", "gif"):
        return file_data, filename

    try:
        img = Image.open(io.BytesIO(file_data))

        # Convert RGBA to RGB for JPEG (can't save RGBA as JPEG)
        if ext in ("jpg", "jpeg") and img.mode == "RGBA":
            # Create white background
            background = Image.new("RGB", img.size, (255, 255, 255))
            background.paste(img, mask=img.split()[3])  # 3 is the alpha channel
            img = background

        # Resize if too wide
        if img.width > MAX_IMAGE_WIDTH:
            ratio = MAX_IMAGE_WIDTH / img.width
            new_height = int(img.height * ratio)
            img = img.resize((MAX_IMAGE_WIDTH, new_height), Image.Resampling.LANCZOS)
            print(f"Resized image from {img.width}x{img.height} to {MAX_IMAGE_WIDTH}x{new_height}")

        # Save with compression
        output = io.BytesIO()

        if ext in ("jpg", "jpeg"):
            # Ensure RGB mode for JPEG
            if img.mode != "RGB":
                img = img.convert("RGB")
            img.save(output, format="JPEG", quality=JPEG_QUALITY, optimize=True)
        elif ext == "png":
            img.save(output, format="PNG", optimize=True, compress_level=PNG_COMPRESS_LEVEL)
        elif ext == "webp":
            img.save(output, format="WEBP", quality=JPEG_QUALITY, optimize=True)
        else:
            # Unknown format, return original
            return file_data, filename

        processed_data = output.getvalue()

        # Only use processed version if it's actually smaller
        if len(processed_data) < len(file_data):
            print(f"Compressed image: {len(file_data)} -> {len(processed_data)} bytes ({100 * len(processed_data) // len(file_data)}%)")
            return processed_data, filename
        else:
            print(f"Keeping original: processed ({len(processed_data)}) >= original ({len(file_data)})")
            return file_data, filename

    except Exception as e:
        print(f"Error processing image: {e}")
        # Return original on error
        return file_data, filename


# Routes

@app.route("/")
def index():
    """Serve the editor HTML."""
    return send_file(EDITOR_DIR / "editor.html")


@app.route("/api/posts", methods=["GET"])
def list_posts():
    """List all blog posts."""
    return jsonify(get_post_list())


@app.route("/api/posts/<filename>", methods=["GET"])
def get_post(filename: str):
    """Get a single post's full content."""
    filepath = BLOG_DIR / filename
    if not filepath.exists() or not filepath.is_file():
        return jsonify({"error": "Post not found"}), 404

    content = filepath.read_text(encoding="utf-8")
    metadata, body = parse_frontmatter(content)

    return jsonify({
        "filename": filename,
        "title": metadata.get("title", ""),
        "date": metadata.get("date", ""),
        "author": metadata.get("author", ""),
        "status": metadata.get("status", ""),
        "body": body,
    })


@app.route("/api/posts/<filename>", methods=["PUT"])
def save_post(filename: str):
    """Save/update a post."""
    filepath = BLOG_DIR / filename
    data = request.get_json()

    if not data:
        return jsonify({"error": "No data provided"}), 400

    metadata = {
        "title": data.get("title", ""),
        "date": data.get("date", ""),
        "author": data.get("author", "Elias Dorneles"),
        "status": data.get("status", "draft"),
    }
    body = data.get("body", "")

    content = build_frontmatter(metadata) + "\n\n" + body
    filepath.write_text(content, encoding="utf-8")

    return jsonify({"success": True, "filename": filename})


@app.route("/api/posts", methods=["POST"])
def create_post():
    """Create a new post."""
    data = request.get_json()
    title = data.get("title", "New Blog Post")
    now = datetime.now()
    date = now.strftime("%Y-%m-%d %H:%M")

    slug = title_to_slug(title)
    filename = f"{slug}.md"
    filepath = BLOG_DIR / filename

    # Ensure unique filename
    counter = 1
    while filepath.exists():
        filename = f"{slug}-{counter}.md"
        filepath = BLOG_DIR / filename
        counter += 1

    metadata = {
        "title": title,
        "date": date,
        "author": "Elias Dorneles",
        "status": "draft",
    }
    body = "Write here..."

    content = build_frontmatter(metadata) + "\n\n" + body
    filepath.write_text(content, encoding="utf-8")

    return jsonify({
        "success": True,
        "filename": filename,
        "title": title,
        "date": date,
        "status": "draft",
    })


@app.route("/api/images", methods=["GET"])
def list_images():
    """List all images in the images directory."""
    images = []
    for ext in ALLOWED_IMAGE_EXTENSIONS:
        for filepath in IMAGES_DIR.glob(f"*.{ext}"):
            images.append({
                "filename": filepath.name,
                "url": f"/static/images/{filepath.name}",
            })
        for filepath in IMAGES_DIR.glob(f"*.{ext.upper()}"):
            images.append({
                "filename": filepath.name,
                "url": f"/static/images/{filepath.name}",
            })

    # Sort by modification time, newest first
    images.sort(key=lambda x: (IMAGES_DIR / x["filename"]).stat().st_mtime, reverse=True)
    return jsonify(images)


@app.route("/api/images", methods=["POST"])
def upload_image():
    """Upload a new image with automatic resize and compression."""
    if "file" not in request.files:
        return jsonify({"error": "No file provided"}), 400

    file = request.files["file"]
    if not file.filename:
        return jsonify({"error": "No filename"}), 400

    # Validate extension
    ext = file.filename.rsplit(".", 1)[-1].lower() if "." in file.filename else ""
    if ext not in ALLOWED_IMAGE_EXTENSIONS:
        return jsonify({"error": f"Invalid file type. Allowed: {', '.join(ALLOWED_IMAGE_EXTENSIONS)}"}), 400

    filename = sanitize_filename(file.filename)

    # Read file data and process image
    file_data = file.read()
    processed_data, filename = process_image(file_data, filename)

    filepath = IMAGES_DIR / filename

    # Ensure unique filename
    counter = 1
    base, ext_with_dot = os.path.splitext(filename)
    while filepath.exists():
        filename = f"{base}_{counter}{ext_with_dot}"
        filepath = IMAGES_DIR / filename
        counter += 1

    # Write processed image
    filepath.write_bytes(processed_data)

    return jsonify({
        "success": True,
        "filename": filename,
        "url": f"/static/images/{filename}",
    })


@app.route("/static/images/<path:filename>")
def serve_image(filename: str):
    """Serve images for preview."""
    return send_from_directory(IMAGES_DIR, filename)


@app.route("/static/editor.css")
def serve_editor_css():
    """Serve editor CSS."""
    return send_file(EDITOR_DIR / "editor.css", mimetype="text/css")


@app.route("/static/editor.js")
def serve_editor_js():
    """Serve editor JavaScript."""
    return send_file(EDITOR_DIR / "editor.js", mimetype="application/javascript")


if __name__ == "__main__":
    print(f"Blog directory: {BLOG_DIR}")
    print(f"Images directory: {IMAGES_DIR}")
    print("Starting editor at http://127.0.0.1:5000")
    app.run(host="127.0.0.1", port=5000, debug=True)
