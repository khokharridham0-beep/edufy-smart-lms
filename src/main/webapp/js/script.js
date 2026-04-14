/* AI Assignment Management System - Main JS */

// ── Modal helpers ────────────────────────────────────────
function openModal(id) {
  document.getElementById(id).classList.add('open');
}
function closeModal(id) {
  document.getElementById(id).classList.remove('open');
}
// Close modal on overlay click
document.addEventListener('click', function(e) {
  if (e.target.classList.contains('modal-overlay')) {
    e.target.classList.remove('open');
  }
});

// ── Populate edit form ───────────────────────────────────
function populateEdit(btn) {
  const data = btn.dataset;
  const formId = data.form;
  const form = document.getElementById(formId);
  if (!form) return;
  Object.keys(data).forEach(key => {
    if (key === 'form') return;
    const el = form.querySelector('[name="' + key + '"]');
    if (el) el.value = data[key];
  });
  const modalId = data.modal || (formId.replace('Form', 'Modal'));
  openModal(modalId);
}

// ── Dynamic module load by course ───────────────────────
function loadModulesByCourse(courseId, targetSelectId) {
  if (!courseId) return;
  fetch(contextPath + '/api/modules?courseId=' + courseId)
    .then(r => r.json())
    .then(modules => {
      const sel = document.getElementById(targetSelectId);
      if (!sel) return;
      sel.innerHTML = '<option value="">-- Select Module --</option>';
      modules.forEach(m => {
        sel.innerHTML += '<option value="' + m.id + '">' + m.moduleName + '</option>';
      });
    })
    .catch(() => {});
}

// ── Module accordion toggle ──────────────────────────────
document.addEventListener('click', function(e) {
  const header = e.target.closest('.module-header[data-toggle]');
  if (!header) return;
  const body = header.nextElementSibling;
  if (!body) return;
  const isOpen = body.style.display !== 'none';
  body.style.display = isOpen ? 'none' : 'block';
  const icon = header.querySelector('.toggle-icon');
  if (icon) icon.textContent = isOpen ? '▸' : '▾';
});

// ── Auto-dismiss alerts ──────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('.alert[data-auto-dismiss]').forEach(el => {
    setTimeout(() => {
      el.style.transition = 'opacity .5s';
      el.style.opacity = '0';
      setTimeout(() => el.remove(), 500);
    }, 4000);
  });

  // Sidebar mobile toggle
  const toggle = document.getElementById('sidebarToggle');
  const sidebar = document.querySelector('.sidebar');
  if (toggle && sidebar) {
    toggle.addEventListener('click', () => sidebar.classList.toggle('open'));
  }
});

// ── Confirm delete ───────────────────────────────────────
function confirmDelete(url, name) {
  if (confirm('Delete "' + name + '"? This cannot be undone.')) {
    window.location.href = url;
  }
}

// ── Keywords tag input ───────────────────────────────────
function initKeywordInput(inputId, displayId) {
  const input = document.getElementById(inputId);
  const display = document.getElementById(displayId);
  if (!input || !display) return;
  input.addEventListener('keydown', function(e) {
    if (e.key === ',' || e.key === 'Enter') {
      e.preventDefault();
      addTag(this.value.trim(), input, display);
      this.value = '';
    }
  });
}

function addTag(text, input, display) {
  if (!text) return;
  const hidden = input.previousElementSibling || input;
  const existing = hidden.value ? hidden.value.split(',') : [];
  if (existing.includes(text)) return;
  existing.push(text);
  hidden.value = existing.join(',');
  const tag = document.createElement('span');
  tag.className = 'badge badge-teal';
  tag.style.margin = '2px';
  tag.innerHTML = text + ' <span onclick="removeTag(this, \'' + text + '\')" style="cursor:pointer;margin-left:4px;">×</span>';
  display.appendChild(tag);
}

function removeTag(span, text) {
  const container = span.closest('.tag-display');
  if (!container) return;
  const hidden = container.previousElementSibling;
  let arr = hidden.value.split(',').filter(t => t !== text);
  hidden.value = arr.join(',');
  span.parentElement.remove();
}
