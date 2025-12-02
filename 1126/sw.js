const CACHE_NAME = 'mood-player-v1';
const ASSETS = [
  '/',
  '/index.html',
  '/styles.css',
  '/app.js',
  '/config.js',
  '/particles.js',
  '/mobile-menu.js',
  '/manifest.json'
];

self.addEventListener('install', (evt) => {
  evt.waitUntil(
    caches.open(CACHE_NAME).then(cache => cache.addAll(ASSETS)).then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', (evt) => {
  evt.waitUntil(
    caches.keys().then(keys => Promise.all(
      keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k))
    )).then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', (evt) => {
  const req = evt.request;
  // 네트워크 우선, 실패 시 캐시 폴백 (앱의 요구에 따라 변경)
  evt.respondWith(
    fetch(req).catch(() => caches.match(req)).catch(() => caches.match('/index.html'))
  );
});
