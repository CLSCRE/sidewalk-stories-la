(function () {
  var store = SSLAApp.ensureStore();
  var mapEl = document.getElementById('map');
  var listEl = document.getElementById('list');
  var countEl = document.getElementById('map-count');
  var map, layer;
  function escapeHtml(s) {
    return String(s || '').replace(/[&<>"']/g, function (c) {
      if (c === '&') return '&' + 'amp;';
      if (c === '<') return '&' + 'lt;';
      if (c === '>') return '&' + 'gt;';
      if (c === '"') return '&' + 'quot;';
      return '&#39;';
    });
  }
  function card(r) {
    var d = document.createElement('div');
    d.className = 'report-card';
    var left = r.photoDataUrl
      ? ('<img src="' + r.photoDataUrl + '" alt="">')
      : '<div class="thumb-empty">SSLA</div>';
    d.innerHTML = left + '<div><div><span class="pill ' + (r.status || 'new') + '">' + (r.status || 'new') + '</span></div>' +
      '<div><strong>' + escapeHtml(r.address || 'No address') + '</strong></div>' +
      '<div class="meta">' + escapeHtml(r.neighborhood || '') + ' | ' + SSLAApp.fmtDate(r.createdAt) + '</div>' +
      '<div class="meta">' + escapeHtml(r.damage || '') + ' | ' + escapeHtml(r.name || '') + '</div></div>';
    return d;
  }
  function render() {
    var rows = store.list();
    countEl.textContent = rows.length + ' report(s) on this device';
    layer.clearLayers();
    var bounds = [];
    listEl.innerHTML = '';
    rows.forEach(function (r) {
      if (r.lat != null && r.lng != null && !isNaN(r.lat) && !isNaN(r.lng)) {
        var m = L.marker([r.lat, r.lng]).addTo(layer);
        m.bindPopup('<strong>' + escapeHtml(r.address || 'Panel') + '</strong><br>' + escapeHtml(r.status || 'new') + '<br>' + escapeHtml(r.damage || ''));
        bounds.push([r.lat, r.lng]);
      }
      listEl.appendChild(card(r));
    });
    if (bounds.length) map.fitBounds(bounds, { padding: [30, 30], maxZoom: 17 });
  }
  function init() {
    map = L.map(mapEl).setView([34.076, -118.361], 14);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', { maxZoom: 19, attribution: '&copy; OpenStreetMap' }).addTo(map);
    layer = L.layerGroup().addTo(map);
    render();
    setTimeout(function () { map.invalidateSize(); }, 150);
  }
  document.getElementById('btn-refresh').onclick = render;
  window.addEventListener('ssla-panels-updated', render);
  init();
})();
