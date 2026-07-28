/* report-panel page controller */
(function () {
  const cfg = window.SSLA_PANEL_CONFIG || {};
  const store = window.SSLAPanelStore;
  if (!store) { console.error('SSLAPanelStore missing'); return; }

  const el = (id) => document.getElementById(id);
  const form = el('panel-report-form');
  if (!form) return;

  const status = el('form-status');
  const coordsLabel = el('coords-label');
  const latInput = el('lat');
  const lngInput = el('lng');
  const addressInput = el('address');
  const photoInput = el('photo');
  const preview = el('photo-preview');
  const localCount = el('local-count');
  const googleLink = el('google-form-link');
  const btnLocate = el('btn-locate');
  const btnClear = el('btn-clear-pin');
  const btnSubmit = el('btn-submit');

  let photoDataUrl = null;
  let map = null;
  let marker = null;

  function setStatus(type, msg) {
    if (!status) return;
    status.className = 'form-status ' + type;
    status.textContent = msg;
  }

  function refreshCount() {
    if (!localCount) return;
    const n = store.list().length;
    localCount.textContent = n === 0
      ? 'No reports saved in this browser yet.'
      : n + ' report(s) saved in this browser. Open admin to triage.';
  }

  function setPin(lat, lng, pan) {
    latInput.value = lat != null ? Number(lat).toFixed(6) : '';
    lngInput.value = lng != null ? Number(lng).toFixed(6) : '';
    if (lat == null || lng == null) {
      coordsLabel.textContent = 'No pin yet - tap the map or use GPS.';
      if (marker && map) { map.removeLayer(marker); marker = null; }
      return;
    }
    coordsLabel.textContent = 'Pin: ' + Number(lat).toFixed(5) + ', ' + Number(lng).toFixed(5);
    if (!map || typeof L === 'undefined') return;
    const ll = [Number(lat), Number(lng)];
    if (!marker) {
      marker = L.marker(ll, { draggable: true }).addTo(map);
      marker.on('dragend', async function () {
        const p = marker.getLatLng();
        setPin(p.lat, p.lng, false);
        const name = await store.reverseGeocode(p.lat, p.lng);
        if (name && addressInput && !addressInput.dataset.userEdited) addressInput.value = name;
      });
    } else {
      marker.setLatLng(ll);
    }
    if (pan !== false) map.setView(ll, Math.max(map.getZoom(), 17));
  }

  function initMap() {
    const host = el('report-map');
    if (!host || typeof L === 'undefined') return;
    map = L.map(host, { scrollWheelZoom: false }).setView([34.076, -118.361], 14);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      maxZoom: 19,
      attribution: '&copy; OpenStreetMap'
    }).addTo(map);
    map.on('click', async function (e) {
      setPin(e.latlng.lat, e.latlng.lng, false);
      const name = await store.reverseGeocode(e.latlng.lat, e.latlng.lng);
      if (name && addressInput && !addressInput.dataset.userEdited) addressInput.value = name;
    });
    setTimeout(function () { map.invalidateSize(); }, 200);
  }

  if (googleLink && cfg.googleFormUrl) googleLink.href = cfg.googleFormUrl;

  if (addressInput) {
    addressInput.addEventListener('input', function () {
      addressInput.dataset.userEdited = '1';
    });
  }

  if (photoInput) {
    photoInput.addEventListener('change', async function () {
      const file = photoInput.files && photoInput.files[0];
      photoDataUrl = null;
      if (!file) { preview.style.display = 'none'; return; }
      try {
        setStatus('info', 'Compressing photo...');
        photoDataUrl = await store.compressImage(file);
        if (photoDataUrl) {
          preview.src = photoDataUrl;
          preview.style.display = 'block';
          setStatus('info', 'Photo ready.');
        }
      } catch (e) {
        setStatus('err', 'Could not process photo. Try a smaller image.');
      }
    });
  }

  if (btnLocate) {
    btnLocate.addEventListener('click', function () {
      if (!navigator.geolocation) {
        setStatus('err', 'Geolocation is not available on this device.');
        return;
      }
      setStatus('info', 'Getting your location...');
      btnLocate.disabled = true;
      navigator.geolocation.getCurrentPosition(async function (pos) {
        btnLocate.disabled = false;
        const lat = pos.coords.latitude;
        const lng = pos.coords.longitude;
        setPin(lat, lng, true);
        const name = await store.reverseGeocode(lat, lng);
        if (name && addressInput && !addressInput.dataset.userEdited) addressInput.value = name;
        setStatus('ok', 'Location pinned. Adjust the pin if needed.');
      }, function (err) {
        btnLocate.disabled = false;
        setStatus('err', 'Could not get location. Allow location access or drop a pin manually.');
        console.warn(err);
      }, { enableHighAccuracy: true, timeout: 15000 });
    });
  }

  if (btnClear) {
    btnClear.addEventListener('click', function () { setPin(null, null); });
  }

  form.addEventListener('submit', async function (e) {
    e.preventDefault();
    setStatus('info', 'Saving report...');
    btnSubmit.disabled = true;
    try {
      const report = await store.submit({
        name: el('name').value,
        email: el('email').value,
        phone: el('phone').value,
        neighborhood: el('neighborhood').value,
        address: addressInput.value,
        lat: latInput.value,
        lng: lngInput.value,
        damage: el('damage').value,
        notes: el('notes').value,
        photoDataUrl: photoDataUrl,
        source: 'report-panel'
      });
      let msg = 'Saved report ' + report.id + ' on this device.';
      if (report.remote) {
        const ok = (report.remote.formspree && report.remote.formspree.ok) || (report.remote.webhook && report.remote.webhook.ok);
        if (ok) msg += ' Cloud copy sent.';
        else if (cfg.formspreeEndpoint || cfg.webhookUrl) msg += ' Cloud copy failed - still saved locally.';
        else msg += ' (Local only - add Formspree/webhook in js/panel-config.js to email copies.)';
      }
      setStatus('ok', msg);
      form.reset();
      photoDataUrl = null;
      preview.style.display = 'none';
      if (addressInput) delete addressInput.dataset.userEdited;
      setPin(null, null);
      refreshCount();
    } catch (err) {
      setStatus('err', err.message || 'Could not save report.');
    }
    btnSubmit.disabled = false;
  });

  window.addEventListener('ssla-panels-updated', refreshCount);
  initMap();
  refreshCount();
})();
