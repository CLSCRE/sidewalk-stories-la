(function () {
  var store = SSLAApp.ensureStore();
  var cfg = window.SSLA_PANEL_CONFIG || {};
  var gateCard = document.getElementById('gate-card');
  var adminApp = document.getElementById('admin-app');
  var gateStatus = document.getElementById('gate-status');
  var pinInput = document.getElementById('pin');
  var listEl = document.getElementById('admin-list');
  var countEl = document.getElementById('admin-count');
  var filterEl = document.getElementById('filter-status');
  var map, layer;

  function esc(s) {
    return String(s || '').replace(/[&<>"']/g, function (c) {
      if (c === '&') return '&' + 'amp;';
      if (c === '<') return '&' + 'lt;';
      if (c === '>') return '&' + 'gt;';
      if (c === '"') return '&' + 'quot;';
      return '&#39;';
    });
  }

  function unlock() {
    gateCard.style.display = 'none';
    adminApp.style.display = 'block';
    if (!map) {
      map = L.map('admin-map').setView([34.076, -118.361], 14);
      L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 19,
        attribution: '&copy; OpenStreetMap'
      }).addTo(map);
      layer = L.layerGroup().addTo(map);
      setTimeout(function () { map.invalidateSize(); }, 150);
    }
    render();
  }

  function makeRow(r) {
    var wrap = document.createElement('div');
    wrap.className = 'report-card';
    var left = r.photoDataUrl
      ? ('<img src="' + r.photoDataUrl + '" alt="">')
      : '<div class="thumb-empty">SSLA</div>';
    var body = document.createElement('div');
    body.innerHTML =
      '<div><span class="pill ' + (r.status || 'new') + '">' + (r.status || 'new') + '</span> <code>' + esc(r.id) + '</code></div>' +
      '<div><strong>' + esc(r.address || 'No address') + '</strong></div>' +
      '<div class="meta">' + esc(r.name) + ' | ' + esc(r.email) + ' | ' + SSLAApp.fmtDate(r.createdAt) + '</div>' +
      '<div class="meta">' + esc(r.damage || '') + ' | ' + esc(r.neighborhood || '') + '</div>' +
      (r.notes ? ('<div class="meta">' + esc(r.notes) + '</div>') : '') +
      (r.lat != null ? ('<div class="meta">' + r.lat + ', ' + r.lng + '</div>') : '');
    var actions = document.createElement('div');
    actions.className = 'row-actions';
    ['new', 'reviewed', 'shortlist', 'selected', 'rejected'].forEach(function (st) {
      var btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'btn btn-ghost';
      btn.textContent = st;
      btn.onclick = function () { store.updateStatus(r.id, st); render(); };
      actions.appendChild(btn);
    });
    var del = document.createElement('button');
    del.type = 'button';
    del.className = 'btn btn-ghost';
    del.textContent = 'Delete';
    del.onclick = function () {
      if (confirm('Delete this report?')) { store.remove(r.id); render(); }
    };
    actions.appendChild(del);
    body.appendChild(actions);
    wrap.innerHTML = left;
    wrap.appendChild(body);
    return wrap;
  }

  function render() {
    var st = filterEl.value || 'all';
    var rows = store.list(st);
    countEl.textContent = rows.length + ' report(s)';
    layer.clearLayers();
    listEl.innerHTML = '';
    var bounds = [];
    rows.forEach(function (r) {
      if (r.lat != null && r.lng != null && !isNaN(r.lat) && !isNaN(r.lng)) {
        var m = L.marker([r.lat, r.lng]).addTo(layer);
        m.bindPopup(esc(r.address || r.id));
        bounds.push([r.lat, r.lng]);
      }
      listEl.appendChild(makeRow(r));
    });
    if (bounds.length) map.fitBounds(bounds, { padding: [24, 24], maxZoom: 17 });
  }

  function dl(name, text, mime) {
    var blob = new Blob([text], { type: mime || 'text/plain' });
    var a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = name;
    a.click();
    URL.revokeObjectURL(a.href);
  }

  document.getElementById('btn-unlock').onclick = function () {
    var pin = (pinInput.value || '').trim();
    var expected = String(cfg.adminPin || 'sidewalk2026');
    if (pin === expected) {
      sessionStorage.setItem('ssla_admin_ok', '1');
      unlock();
    } else {
      SSLAApp.status(gateStatus, 'err', 'Wrong PIN');
    }
  };

  filterEl.onchange = render;
  document.getElementById('btn-refresh').onclick = render;
  document.getElementById('btn-export-json').onclick = function () {
    dl('ssla-panels.json', store.exportJson(), 'application/json');
  };
  document.getElementById('btn-export-csv').onclick = function () {
    dl('ssla-panels.csv', store.exportCsv(), 'text/csv');
  };

  if (sessionStorage.getItem('ssla_admin_ok') === '1') unlock();
})();
