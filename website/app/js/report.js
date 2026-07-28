(function () {
  var store = SSLAApp.ensureStore();
  var form = document.getElementById('app-report-form');
  var statusEl = document.getElementById('status');
  var coordsLabel = document.getElementById('coords-label');
  var latInput = document.getElementById('lat');
  var lngInput = document.getElementById('lng');
  var addressInput = document.getElementById('address');
  var photoInput = document.getElementById('photo');
  var preview = document.getElementById('photo-preview');
  var btnLocate = document.getElementById('btn-locate');
  var btnClear = document.getElementById('btn-clear');
  var btnSubmit = document.getElementById('btn-submit');
  var photoDataUrl = null;
  var map, marker;

  function setStatus(type, msg) { SSLAApp.status(statusEl, type, msg); }

  function setPin(lat, lng, pan) {
    latInput.value = lat != null ? Number(lat).toFixed(6) : '';
    lngInput.value = lng != null ? Number(lng).toFixed(6) : '';
    if (lat == null || lng == null) {
      coordsLabel.textContent = 'No pin yet.';
      if (marker) { map.removeLayer(marker); marker = null; }
      return;
    }
    coordsLabel.textContent = 'Pin: ' + Number(lat).toFixed(5) + ', ' + Number(lng).toFixed(5);
    var ll = [Number(lat), Number(lng)];
    if (!marker) {
      marker = L.marker(ll, { draggable: true }).addTo(map);
      marker.on('dragend', function () {
        var p = marker.getLatLng();
        setPin(p.lat, p.lng, false);
        store.reverseGeocode(p.lat, p.lng).then(function (name) {
          if (name && !addressInput.dataset.userEdited) addressInput.value = name;
        });
      });
    } else {
      marker.setLatLng(ll);
    }
    if (pan !== false) map.setView(ll, Math.max(map.getZoom(), 17));
  }

  map = L.map('map', { scrollWheelZoom: false }).setView([34.076, -118.361], 14);
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 19,
    attribution: '&copy; OpenStreetMap'
  }).addTo(map);
  map.on('click', function (e) {
    setPin(e.latlng.lat, e.latlng.lng, false);
    store.reverseGeocode(e.latlng.lat, e.latlng.lng).then(function (name) {
      if (name && !addressInput.dataset.userEdited) addressInput.value = name;
    });
  });
  setTimeout(function () { map.invalidateSize(); }, 150);

  addressInput.addEventListener('input', function () {
    addressInput.dataset.userEdited = '1';
  });

  photoInput.addEventListener('change', function () {
    var file = photoInput.files && photoInput.files[0];
    photoDataUrl = null;
    if (!file) { preview.style.display = 'none'; return; }
    setStatus('info', 'Compressing photo...');
    store.compressImage(file).then(function (url) {
      photoDataUrl = url;
      if (url) {
        preview.src = url;
        preview.style.display = 'block';
        setStatus('info', 'Photo ready.');
      }
    }).catch(function () {
      setStatus('err', 'Could not process photo.');
    });
  });

  btnLocate.addEventListener('click', function () {
    if (!navigator.geolocation) {
      setStatus('err', 'Geolocation not available.');
      return;
    }
    setStatus('info', 'Getting location...');
    btnLocate.disabled = true;
    navigator.geolocation.getCurrentPosition(function (pos) {
      btnLocate.disabled = false;
      setPin(pos.coords.latitude, pos.coords.longitude, true);
      store.reverseGeocode(pos.coords.latitude, pos.coords.longitude).then(function (name) {
        if (name && !addressInput.dataset.userEdited) addressInput.value = name;
      });
      setStatus('ok', 'Location pinned.');
    }, function () {
      btnLocate.disabled = false;
      setStatus('err', 'Could not get location. Drop a pin on the map.');
    }, { enableHighAccuracy: true, timeout: 15000 });
  });

  btnClear.addEventListener('click', function () { setPin(null, null); });

  form.addEventListener('submit', function (e) {
    e.preventDefault();
    setStatus('info', 'Saving...');
    btnSubmit.disabled = true;
    store.submit({
      name: document.getElementById('name').value,
      email: document.getElementById('email').value,
      phone: document.getElementById('phone').value,
      neighborhood: document.getElementById('neighborhood').value,
      address: addressInput.value,
      lat: latInput.value,
      lng: lngInput.value,
      damage: document.getElementById('damage').value,
      notes: document.getElementById('notes').value,
      photoDataUrl: photoDataUrl,
      source: 'app-report'
    }).then(function (report) {
      var msg = 'Saved ' + report.id + ' on this device.';
      var cfg = window.SSLA_PANEL_CONFIG || {};
      if (report.remote) {
        var ok = (report.remote.formspree && report.remote.formspree.ok) || (report.remote.webhook && report.remote.webhook.ok);
        if (ok) msg += ' Cloud copy sent.';
        else if (cfg.formspreeEndpoint || cfg.webhookUrl) msg += ' Cloud failed; local OK.';
        else msg += ' Local only.';
      }
      setStatus('ok', msg);
      form.reset();
      photoDataUrl = null;
      preview.style.display = 'none';
      delete addressInput.dataset.userEdited;
      setPin(null, null);
      btnSubmit.disabled = false;
    }).catch(function (err) {
      setStatus('err', err.message || 'Save failed');
      btnSubmit.disabled = false;
    });
  });
})();
