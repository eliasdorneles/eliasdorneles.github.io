(function() {
  'use strict';

  var overlay = null;
  var viewerImage = null;

  function createOverlay() {
    overlay = document.createElement('div');
    overlay.className = 'imgviewer-overlay';

    var closeBtn = document.createElement('button');
    closeBtn.className = 'imgviewer-close';
    closeBtn.innerHTML = '&times;';
    closeBtn.setAttribute('aria-label', 'Close image viewer');

    viewerImage = document.createElement('img');
    viewerImage.className = 'imgviewer-image';

    overlay.appendChild(closeBtn);
    overlay.appendChild(viewerImage);
    document.body.appendChild(overlay);

    overlay.addEventListener('click', function(e) {
      if (e.target === overlay || e.target === closeBtn) {
        closeViewer();
      }
    });
  }

  function openViewer(src) {
    if (!overlay) {
      createOverlay();
    }
    viewerImage.src = src;
    overlay.classList.add('imgviewer-visible');
    document.body.style.overflow = 'hidden';
  }

  function closeViewer() {
    if (overlay) {
      overlay.classList.remove('imgviewer-visible');
      document.body.style.overflow = '';
    }
  }

  function handleKeydown(e) {
    if (e.key === 'Escape' && overlay && overlay.classList.contains('imgviewer-visible')) {
      closeViewer();
    }
  }

  function init() {
    var articleContent = document.querySelector('.entry-content');
    if (!articleContent) return;

    var images = articleContent.querySelectorAll('img');
    images.forEach(function(img) {
      img.style.cursor = 'zoom-in';
      img.addEventListener('click', function(e) {
        e.preventDefault();
        openViewer(img.src);
      });
    });

    document.addEventListener('keydown', handleKeydown);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
