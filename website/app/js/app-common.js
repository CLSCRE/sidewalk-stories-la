window.SSLAApp = {
  qs: (s, r) => (r || document).querySelector(s),
  qsa: (s, r) => Array.from((r || document).querySelectorAll(s)),
  setActiveNav: function (key) {
    this.qsa('[data-nav]').forEach(function (a) {
      a.classList.toggle('active', a.getAttribute('data-nav') === key);
    });
  },
  status: function (el, type, msg) {
    if (!el) return;
    el.className = 'status show ' + type;
    el.textContent = msg;
  },
  fmtDate: function (iso) {
    try { return new Date(iso).toLocaleString(); } catch (e) { return iso || ''; }
  },
  ensureStore: function () {
    if (!window.SSLAPanelStore) throw new Error('Panel store not loaded');
    return window.SSLAPanelStore;
  }
};
