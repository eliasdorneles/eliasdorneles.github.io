// State
let posts = [];
let currentPost = null;
let currentFilter = 'all';
let autoSaveTimeout = null;
let previewTimeout = null;
let images = [];
let widthMode = 'auto'; // 'auto' or 'custom'
let cmEditor = null; // CodeMirror instance
let editMode = false; // true when editing existing image
let editPosition = null; // { startLine, endLine } of image being edited

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    loadPosts();
    loadImages();
    setupCodeMirror();
    setupDropZone();
    setupKeyboardShortcuts();
    setupWidthToggle();
    setupPreviewClickHandler();
});

// Setup CodeMirror
function setupCodeMirror() {
    const textarea = document.getElementById('postBody');
    cmEditor = CodeMirror.fromTextArea(textarea, {
        mode: 'markdown',
        lineNumbers: false,
        lineWrapping: true,
        theme: 'default',
        autofocus: false,
        viewportMargin: Infinity,
    });

    // Handle changes
    cmEditor.on('change', () => {
        handleBodyInput();
    });
}

// API functions
async function loadPosts() {
    try {
        const response = await fetch('/api/posts');
        posts = await response.json();
        renderPostList();
    } catch (error) {
        console.error('Failed to load posts:', error);
    }
}

async function loadImages() {
    try {
        const response = await fetch('/api/images');
        images = await response.json();
        renderImageGallery();
    } catch (error) {
        console.error('Failed to load images:', error);
    }
}

async function loadPost(filename) {
    try {
        const response = await fetch(`/api/posts/${filename}`);
        currentPost = await response.json();
        currentPost.filename = filename;
        renderEditor();
        updatePreview();

        // Update active state in list
        document.querySelectorAll('.post-item').forEach(el => {
            el.classList.toggle('active', el.dataset.filename === filename);
        });
    } catch (error) {
        console.error('Failed to load post:', error);
    }
}

async function savePost() {
    if (!currentPost) return;

    setSaveStatus('saving', 'Saving...');

    try {
        const response = await fetch(`/api/posts/${currentPost.filename}`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                title: document.getElementById('postTitle').value,
                date: document.getElementById('postDate').value,
                author: 'Elias Dorneles',
                status: document.getElementById('postStatus').value,
                body: cmEditor.getValue(),
            }),
        });

        if (response.ok) {
            setSaveStatus('saved', 'Saved');
            // Reload posts list to update title/status if changed
            loadPosts();
        } else {
            setSaveStatus('error', 'Save failed');
        }
    } catch (error) {
        console.error('Failed to save:', error);
        setSaveStatus('error', 'Save failed');
    }
}

async function createNewPost() {
    const title = prompt('Enter post title:', 'New Blog Post');
    if (!title) return;

    try {
        const response = await fetch('/api/posts', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ title }),
        });

        const data = await response.json();
        if (data.success) {
            await loadPosts();
            loadPost(data.filename);
        }
    } catch (error) {
        console.error('Failed to create post:', error);
    }
}

async function uploadImage(file) {
    const formData = new FormData();
    formData.append('file', file);

    // Show upload progress
    const dropZone = document.getElementById('dropZone');
    const originalText = dropZone.textContent;
    dropZone.innerHTML = 'Uploading... <span class="upload-progress"></span>';

    try {
        const response = await fetch('/api/images', {
            method: 'POST',
            body: formData,
        });

        const data = await response.json();
        dropZone.textContent = originalText;

        if (data.success) {
            await loadImages();
            openImageModal(data.url, data.filename);
        } else {
            alert('Upload failed: ' + (data.error || 'Unknown error'));
        }
    } catch (error) {
        console.error('Failed to upload image:', error);
        dropZone.textContent = originalText;
        alert('Failed to upload image');
    }
}

// Rendering functions
function renderPostList() {
    const container = document.getElementById('postList');
    const search = document.getElementById('searchInput').value.toLowerCase();

    const filtered = posts.filter(post => {
        const matchesSearch = post.title.toLowerCase().includes(search);
        const matchesFilter = currentFilter === 'all' ||
            (currentFilter === 'draft' && post.status === 'draft') ||
            (currentFilter === 'published' && post.status !== 'draft');
        return matchesSearch && matchesFilter;
    });

    container.innerHTML = filtered.map(post => `
        <div class="post-item ${currentPost?.filename === post.filename ? 'active' : ''}"
             data-filename="${post.filename}"
             onclick="loadPost('${post.filename}')">
            <div class="post-item-title">${escapeHtml(post.title)}</div>
            <div class="post-item-meta">
                ${post.date ? post.date.split(' ')[0] : 'No date'}
                <span class="status-badge status-${post.status === 'draft' ? 'draft' : 'published'}">
                    ${post.status || 'published'}
                </span>
            </div>
        </div>
    `).join('');
}

function renderImageGallery() {
    const container = document.getElementById('imageGallery');
    container.innerHTML = images.slice(0, 12).map(img => `
        <div class="gallery-image" onclick="openImageModal('${img.url}', '${img.filename}')">
            <img src="${img.url}" alt="${img.filename}" loading="lazy">
        </div>
    `).join('');
}

function renderEditor() {
    if (!currentPost) {
        document.getElementById('editorContent').style.display = 'none';
        document.getElementById('editorEmpty').style.display = 'flex';
        return;
    }

    document.getElementById('editorContent').style.display = 'flex';
    document.getElementById('editorEmpty').style.display = 'none';

    document.getElementById('postTitle').value = currentPost.title || '';
    document.getElementById('postDate').value = currentPost.date || '';
    document.getElementById('postStatus').value = currentPost.status || 'draft';
    cmEditor.setValue(currentPost.body || '');

    setSaveStatus('ready', 'Ready');
}

function updatePreview() {
    const body = cmEditor ? cmEditor.getValue() : '';
    const title = document.getElementById('postTitle')?.value || '';

    // Replace {static}/images/ with actual image path for preview
    let previewContent = body.replace(/\{static\}\/images\//g, '/static/images/');

    // Parse markdown
    const html = marked.parse(previewContent);

    document.getElementById('previewPanel').innerHTML = `
        <h1>${escapeHtml(title)}</h1>
        ${html}
    `;
}

// UI Helpers
function setFilter(filter) {
    currentFilter = filter;
    document.querySelectorAll('.filter-tab').forEach(tab => {
        tab.classList.toggle('active', tab.dataset.filter === filter);
    });
    renderPostList();
}

function filterPosts() {
    renderPostList();
}

function setSaveStatus(status, text) {
    const indicator = document.getElementById('saveIndicator');
    const statusEl = document.getElementById('saveStatus');
    indicator.className = 'save-indicator ' + status;
    statusEl.textContent = text;
}

function scheduleAutoSave() {
    clearTimeout(autoSaveTimeout);
    setSaveStatus('pending', 'Unsaved changes...');
    autoSaveTimeout = setTimeout(savePost, 1000);
}

function handleBodyInput() {
    scheduleAutoSave();

    // Debounce preview update
    clearTimeout(previewTimeout);
    previewTimeout = setTimeout(updatePreview, 200);
}

function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// Drag and Drop
function setupDropZone() {
    const dropZone = document.getElementById('dropZone');
    const fileInput = document.getElementById('fileInput');
    const editorPanel = document.querySelector('.editor-panel');

    // Click to open file picker
    dropZone.addEventListener('click', (e) => {
        e.stopPropagation();
        fileInput.click();
    });

    // Prevent default drag behaviors on the whole document
    ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
        document.body.addEventListener(eventName, preventDefaults, false);
    });

    function preventDefaults(e) {
        e.preventDefault();
        e.stopPropagation();
    }

    // Highlight drop zone when dragging over it
    ['dragenter', 'dragover'].forEach(eventName => {
        dropZone.addEventListener(eventName, () => {
            dropZone.classList.add('drag-over');
        }, false);
    });

    ['dragleave', 'drop'].forEach(eventName => {
        dropZone.addEventListener(eventName, () => {
            dropZone.classList.remove('drag-over');
        }, false);
    });

    // Handle drop on drop zone
    dropZone.addEventListener('drop', handleDrop, false);

    // Handle drop on CodeMirror (after it's initialized)
    setTimeout(() => {
        const cmWrapper = document.querySelector('.CodeMirror');
        if (cmWrapper) {
            cmWrapper.addEventListener('dragenter', (e) => {
                preventDefaults(e);
                dropZone.classList.add('drag-over');
            });

            cmWrapper.addEventListener('dragover', (e) => {
                preventDefaults(e);
                dropZone.classList.add('drag-over');
            });

            cmWrapper.addEventListener('dragleave', (e) => {
                preventDefaults(e);
                const rect = cmWrapper.getBoundingClientRect();
                if (e.clientX < rect.left || e.clientX >= rect.right ||
                    e.clientY < rect.top || e.clientY >= rect.bottom) {
                    dropZone.classList.remove('drag-over');
                }
            });

            cmWrapper.addEventListener('drop', handleDrop, false);
        }
    }, 100);

    // Handle drop on the entire editor panel as fallback
    editorPanel.addEventListener('dragover', (e) => {
        preventDefaults(e);
    });

    editorPanel.addEventListener('drop', handleDrop, false);

    function handleDrop(e) {
        preventDefaults(e);
        dropZone.classList.remove('drag-over');

        const dt = e.dataTransfer;
        const files = dt.files;

        if (files.length > 0) {
            const file = files[0];
            if (file.type.startsWith('image/')) {
                uploadImage(file);
            } else {
                alert('Please drop an image file (PNG, JPG, GIF, WebP, or SVG)');
            }
        }
    }
}

function handleFileSelect(event) {
    const file = event.target.files[0];
    if (file && file.type.startsWith('image/')) {
        uploadImage(file);
    }
    event.target.value = ''; // Reset input
}

// Width toggle
function setupWidthToggle() {
    const autoBtn = document.getElementById('widthAutoBtn');
    const customBtn = document.getElementById('widthCustomBtn');
    const widthInput = document.getElementById('imageWidth');

    autoBtn.addEventListener('click', () => {
        widthMode = 'auto';
        autoBtn.classList.add('active');
        customBtn.classList.remove('active');
        widthInput.disabled = true;
        widthInput.value = '';
    });

    customBtn.addEventListener('click', () => {
        widthMode = 'custom';
        customBtn.classList.add('active');
        autoBtn.classList.remove('active');
        widthInput.disabled = false;
        widthInput.focus();
        if (!widthInput.value) {
            widthInput.value = '400';
        }
    });
}

// Image Modal
function openImageModal(url, filename) {
    document.getElementById('modalImagePreview').src = url;
    document.getElementById('modalImageUrl').value = filename;
    document.getElementById('imageAlt').value = '';
    document.getElementById('imageCaption').value = '';
    document.getElementById('imageWidth').value = '';
    document.getElementById('imageWidth').disabled = true;

    // Reset width toggle to auto
    widthMode = 'auto';
    document.getElementById('widthAutoBtn').classList.add('active');
    document.getElementById('widthCustomBtn').classList.remove('active');

    document.querySelector('input[name="alignment"][value="none"]').checked = true;
    document.getElementById('imageModal').classList.add('active');

    // Focus alt text field
    setTimeout(() => document.getElementById('imageAlt').focus(), 100);
}

function closeImageModal() {
    document.getElementById('imageModal').classList.remove('active');

    // Reset edit mode
    editMode = false;
    editPosition = null;

    // Reset button text to "Insert"
    const insertBtn = document.getElementById('imageModalSubmit');
    if (insertBtn) {
        insertBtn.textContent = 'Insert';
    }
}

function insertImage() {
    const filename = document.getElementById('modalImageUrl').value;
    const alt = document.getElementById('imageAlt').value || filename;
    const caption = document.getElementById('imageCaption').value;
    const alignment = document.querySelector('input[name="alignment"]:checked').value;
    const width = widthMode === 'custom' ? document.getElementById('imageWidth').value : null;

    let code = '';
    const imgPath = `{static}/images/${filename}`;

    if (caption) {
        // Figure with caption
        const alignClass = alignment !== 'none' ? ` align-${alignment}` : '';
        const styleAttr = width ? ` style="width: ${width}px"` : '';
        code = `<div class="figure${alignClass}"${styleAttr}>
  <img src="${imgPath}" alt="${alt}">
  <p class="caption">${caption}</p>
</div>`;
    } else if (alignment !== 'none' || width) {
        // HTML img with class/width
        const alignClass = alignment !== 'none' ? ` class="align-${alignment}"` : '';
        const widthAttr = width ? ` width="${width}"` : '';
        code = `<img src="${imgPath}"${alignClass}${widthAttr} alt="${alt}" />`;
    } else {
        // Simple markdown
        code = `![${alt}](${imgPath})`;
    }

    if (editMode && editPosition) {
        // Replace existing image
        const endLineContent = cmEditor.getLine(editPosition.endLine);
        cmEditor.replaceRange(
            code,
            { line: editPosition.startLine, ch: 0 },
            { line: editPosition.endLine, ch: endLineContent.length }
        );
        editMode = false;
        editPosition = null;
    } else {
        // Insert at cursor position using CodeMirror
        const cursor = cmEditor.getCursor();
        const line = cmEditor.getLine(cursor.line);

        // Add newlines if not at start of line
        let prefix = '';
        let suffix = '\n\n';
        if (cursor.ch > 0 || line.length > 0) {
            prefix = '\n\n';
        }

        cmEditor.replaceSelection(prefix + code + suffix);
    }

    cmEditor.focus();
    closeImageModal();
    handleBodyInput();
}

// Keyboard shortcuts
function setupKeyboardShortcuts() {
    document.addEventListener('keydown', (e) => {
        // Ctrl+S or Cmd+S to save
        if ((e.ctrlKey || e.metaKey) && e.key === 's') {
            e.preventDefault();
            if (currentPost) {
                clearTimeout(autoSaveTimeout);
                savePost();
            }
        }

        // Alt+N for new post
        if (e.altKey && e.key === 'n') {
            e.preventDefault();
            createNewPost();
        }

        // Escape to close modal
        if (e.key === 'Escape') {
            closeImageModal();
        }

        // Enter in modal to insert
        if (e.key === 'Enter' && document.getElementById('imageModal').classList.contains('active')) {
            // Don't insert if focus is on a text input
            if (document.activeElement.tagName !== 'INPUT') {
                e.preventDefault();
                insertImage();
            }
        }
    });
}

// Preview click-to-edit functionality
function setupPreviewClickHandler() {
    const preview = document.getElementById('previewPanel');
    preview.addEventListener('click', (e) => {
        if (e.target.tagName === 'IMG') {
            handlePreviewImageClick(e.target);
        }
    });
}

function handlePreviewImageClick(imgElement) {
    // Get filename from src (preview uses /static/images/, source uses {static}/images/)
    const src = imgElement.getAttribute('src');
    const filename = src.replace('/static/images/', '');

    // Check if inside a figure
    const figure = imgElement.closest('.figure');

    // Extract current values
    const info = {
        filename: filename,
        alt: imgElement.getAttribute('alt') || '',
        caption: figure ? (figure.querySelector('.caption')?.textContent || '') : '',
        alignment: extractAlignment(figure || imgElement),
        width: extractWidth(figure || imgElement)
    };

    // Find position in source
    const sourcePosition = findImageInSource(filename);
    if (sourcePosition) {
        openImageModalForEdit(info, sourcePosition);
    }
}

function extractAlignment(element) {
    const classList = element.classList;
    if (classList.contains('align-left')) return 'left';
    if (classList.contains('align-right')) return 'right';
    if (classList.contains('align-center')) return 'center';
    return 'none';
}

function extractWidth(element) {
    // Check style attribute for width
    const style = element.getAttribute('style');
    if (style) {
        const match = style.match(/width:\s*(\d+)px/);
        if (match) return match[1];
    }

    // Check width attribute (for img elements)
    const widthAttr = element.getAttribute('width');
    if (widthAttr) return widthAttr;

    return null;
}

function escapeRegex(string) {
    return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

function findImageInSource(filename) {
    const content = cmEditor.getValue();
    const lines = content.split('\n');
    const escapedFilename = escapeRegex(filename);

    // Pattern 1: Markdown ![...]({static}/images/filename)
    const markdownPattern = new RegExp(`!\\[[^\\]]*\\]\\(\\{static\\}/images/${escapedFilename}\\)`);

    // Pattern 2: HTML img <img ... src="{static}/images/filename" ...>
    const imgPattern = new RegExp(`<img[^>]*src=["']\\{static\\}/images/${escapedFilename}["'][^>]*/?>`, 'i');

    // Pattern 3: Figure div containing the filename
    const figureStartPattern = /<div\s+class=["']figure[^"']*["']/i;

    for (let i = 0; i < lines.length; i++) {
        const line = lines[i];

        // Check for markdown image
        if (markdownPattern.test(line)) {
            return { startLine: i, endLine: i };
        }

        // Check for standalone img tag
        if (imgPattern.test(line) && !figureStartPattern.test(line)) {
            return { startLine: i, endLine: i };
        }

        // Check for figure block
        if (figureStartPattern.test(line)) {
            // Look for the filename within this figure block
            let endLine = i;
            let foundFilename = false;
            let blockContent = line;

            // Find the end of the figure block
            for (let j = i; j < lines.length; j++) {
                blockContent += '\n' + lines[j];
                if (lines[j].includes('</div>')) {
                    endLine = j;
                    break;
                }
            }

            // Check if this figure contains our image
            if (blockContent.includes(`{static}/images/${filename}`)) {
                return { startLine: i, endLine: endLine };
            }
        }
    }

    return null;
}

function openImageModalForEdit(info, position) {
    editMode = true;
    editPosition = position;

    // Set modal preview image
    document.getElementById('modalImagePreview').src = `/static/images/${info.filename}`;
    document.getElementById('modalImageUrl').value = info.filename;
    document.getElementById('imageAlt').value = info.alt;
    document.getElementById('imageCaption').value = info.caption;

    // Set alignment
    document.querySelector(`input[name="alignment"][value="${info.alignment}"]`).checked = true;

    // Set width
    if (info.width) {
        widthMode = 'custom';
        document.getElementById('widthAutoBtn').classList.remove('active');
        document.getElementById('widthCustomBtn').classList.add('active');
        document.getElementById('imageWidth').value = info.width;
        document.getElementById('imageWidth').disabled = false;
    } else {
        widthMode = 'auto';
        document.getElementById('widthAutoBtn').classList.add('active');
        document.getElementById('widthCustomBtn').classList.remove('active');
        document.getElementById('imageWidth').value = '';
        document.getElementById('imageWidth').disabled = true;
    }

    // Update button text to "Update"
    const insertBtn = document.getElementById('imageModalSubmit');
    if (insertBtn) {
        insertBtn.textContent = 'Update';
    }

    document.getElementById('imageModal').classList.add('active');

    // Focus alt text field
    setTimeout(() => document.getElementById('imageAlt').focus(), 100);
}
