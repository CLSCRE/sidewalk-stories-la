const CACHE = 'ssla-panel-v1';
const ASSETS = [
  './',
  './index.html',
  './report.html',
  './admin.html',
  './css/app.css',
  './js/app-common.js',
  './js/map.js',
  './js/report.js',
  './js/admin.js',
  './manifest.webmanifest',
  '../js/panel-config.js',
  '../js/panel-store.js',
  '../images/logo-signature.jpg'
];
self.addEventListener('install', function (e) {
  e.waitUntil(caches.open(CACHE).then(function (c) { return c.addAll(ASSETS); }));
  self.skipWaiting();
});
self.addEventListener('activate', function (e) {
  e.waitUntil(
    caches.keys().then(function (keys) {
      return Promise.all(keys.filter(function (k) { return k !== CACHE; }).map(function (k) { return caches.delete(k); }));
    })
  );
  self.clients.claim();
});
self.addEventListener('fetch', function (e) {
  if (e.request.method !== 'GET') return;
  e.respondWith(
    caches.match(e.request).then(function (cached) {
      return cached || fetch(e.request).catch(function () { return cached; });
    })
  );
});
