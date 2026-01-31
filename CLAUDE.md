This repository contains the code for my website.

## Static Site Generator

The sitegen/ folder contains my homegrown static site generator
written in [Odin](https://odin-lang.org/docs/overview).
It contains also my homegrown template engine, with Jinja-like syntax.

Look at the commands inside the Makefile to see how to compile and run the tests.

## Blog Editor

The manage/editor/ folder contains a web-based blog post editor built with Python (Flask) and vanilla JavaScript.

To run the editor:
```
uv run python manage/editor/editor_server.py
```

Then open http://localhost:5050 in your browser.

### Features
- Create, edit, and delete draft posts
- Publish/unpublish posts (date is set automatically on publish)
- Live markdown preview with CodeMirror editor
- Image upload with drag-and-drop support
- Image insertion modal with alignment/width options
- Click images in preview to edit their properties
- Rename images and automatically update references across posts
- Smart link paste (paste URL on selected text to create markdown link)

### File Structure
- `editor_server.py` - Flask backend with REST API for posts and images
- `editor.html` - Main HTML template
- `editor.js` - Frontend logic
- `editor.css` - Styles
