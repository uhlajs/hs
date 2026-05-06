const overlay = document.getElementById('gallery-overlay');
const overlayImg = overlay?.querySelector('.gallery-overlay__img');
let thumbs = [];
let currentIndex = -1;
let lastTrigger = null;
let isOpen = false;

function show(index) {
  if (!overlayImg || thumbs.length === 0) return;
  const wrapped = (index + thumbs.length) % thumbs.length;
  currentIndex = wrapped;
  const src = thumbs[wrapped].dataset.full;
  if (src) overlayImg.src = src;
}

function open(trigger) {
  if (!overlay || !overlayImg) return;
  thumbs = Array.from(document.querySelectorAll('.gallery-thumb'));
  const idx = thumbs.indexOf(trigger);
  if (idx < 0) return;
  lastTrigger = trigger;
  show(idx);
  overlay.setAttribute('aria-hidden', 'false');
  document.body.style.overflow = 'hidden';
  requestAnimationFrame(() => {
    requestAnimationFrame(() => overlay.classList.add('is-open'));
  });
  isOpen = true;
}

function close() {
  if (!overlay || !overlayImg || !isOpen) return;
  overlay.classList.remove('is-open');
  overlay.setAttribute('aria-hidden', 'true');
  document.body.style.overflow = '';
  isOpen = false;
  setTimeout(() => {
    if (!isOpen) overlayImg.removeAttribute('src');
  }, 320);
  if (lastTrigger) {
    lastTrigger.focus();
    lastTrigger = null;
  }
  currentIndex = -1;
}

function step(delta) {
  if (!isOpen || currentIndex < 0) return;
  show(currentIndex + delta);
}

function wire() {
  if (!overlay) return;

  document.addEventListener('click', (e) => {
    const thumb = e.target.closest('.gallery-thumb');
    if (thumb) {
      open(thumb);
      return;
    }
    const nav = e.target.closest('.gallery-overlay__nav');
    if (nav && isOpen) {
      e.stopPropagation();
      step(nav.dataset.dir === 'next' ? 1 : -1);
      return;
    }
    if (isOpen && e.target === overlay) {
      close();
    }
  });

  document.addEventListener('keydown', (e) => {
    if (!isOpen) return;
    if (e.key === 'Escape') close();
    else if (e.key === 'ArrowRight') step(1);
    else if (e.key === 'ArrowLeft') step(-1);
  });
}

document.addEventListener('DOMContentLoaded', wire);
