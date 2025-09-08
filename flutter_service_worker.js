'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/canvaskit.js.symbols": "58832fbed59e00d2190aa295c4d70360",
"canvaskit/skwasm.wasm": "264db41426307cfc7fa44b95a7772109",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/chromium/canvaskit.js.symbols": "193deaca1a1424049326d4a91ad1d88d",
"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.wasm": "24c77e750a7fa6d474198905249ff506",
"canvaskit/skwasm.js.symbols": "0088242d10d7e7d6d2649d1fe1bda7c1",
"canvaskit/skwasm_heavy.js.symbols": "3c01ec03b5de6d62c34e17014d1decd3",
"canvaskit/canvaskit.wasm": "07b9f5853202304d3b0749d9306573cc",
"canvaskit/skwasm_heavy.wasm": "8034ad26ba2485dab2fd49bdd786837b",
"flutter.js": "888483df48293866f9f41d3d9274a779",
"manifest.json": "cae73a44378d544011ef640401bc430e",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"main.dart.js": "b42282b3d698a5ff5cb283c64496b02c",
"version.json": "ab73209e70790be221a06499be4c6e5f",
"assets/NOTICES": "8c875f916926ce0a264cbf6e02f7f52f",
"assets/fonts/MaterialIcons-Regular.otf": "c7bb27ec9eaca61813165ef1750f24c7",
"assets/AssetManifest.json": "b65fe2b318132d0925ace2707cd181fc",
"assets/assets/pdf/curriculoSMD_25.pdf": "e468c8dbce902fa7e90a5007e3adc095",
"assets/assets/svg/wpp.svg": "cae5152daacb3b5817891ffb15580601",
"assets/assets/images/003-a.png": "749b938ae3916c71bc0bec1abb5bdc73",
"assets/assets/images/007-b.webp": "dec977e384616fccb22f292796e14246",
"assets/assets/images/018-b.webp": "ed34309b8c845d30991f767e54704d4e",
"assets/assets/images/008-a.png": "82e30e20c144c8b5a1c009b06b6b279c",
"assets/assets/images/roll2.png": "1c2399b57d148671e9441d8cb2184a33",
"assets/assets/images/008-b.webp": "d947fe1dc7880f4dda3d25cb089f6355",
"assets/assets/images/traos.png": "c033141d490c28a1a9d2c4b1cf9b91fb",
"assets/assets/images/006-a.png": "096db40756217f380be1ff6b2d098792",
"assets/assets/images/010-a.png": "572d1efa014f480bcb7872e7b99bc6d8",
"assets/assets/images/004-a.png": "ea616e72493d84d4a900c3247864971e",
"assets/assets/images/003-b.webp": "d61bfa3f6becdf5be00b6bbe73f1265d",
"assets/assets/images/016-a.png": "deb553e4d164e00aaabe0fc06b3f21d6",
"assets/assets/images/015-a.png": "b38b504e7d1e55f2cf466d85ad1ea7a4",
"assets/assets/images/009-b.webp": "84517a3f1fa8c43fedfc50e765df8182",
"assets/assets/images/018-a.png": "de0c0d7b3320db40f95ae012e09830c8",
"assets/assets/images/014-b.webp": "d34717c1f0091f50e27ef387a82946ee",
"assets/assets/images/007-a.png": "b79ca2373c1f2f377f68a43f27df649b",
"assets/assets/images/014-a.png": "8ee70153dd6cf50502cc525ead037efb",
"assets/assets/images/015-b.webp": "06e50f0dd86ee40fbcf3368da517bc8a",
"assets/assets/images/001-a.png": "04639d434bb3335a9ac41a3bb00bf7df",
"assets/assets/images/017-a.png": "b4d214a8621fcf9e2b667eea9c819a74",
"assets/assets/images/011-b.webp": "6de5f2eecf68cecc6878de5b985d6f14",
"assets/assets/images/012-b.webp": "017c80375f05e3c57560338bb9d4db18",
"assets/assets/images/002-b.webp": "f56eefe1c1d50b23cbe5b41e49a335ce",
"assets/assets/images/005-b.webp": "50d820f56632e3bbf5e7ed0c8c7eb2fe",
"assets/assets/images/019-b.webp": "55a786b057076fd10bed986dd0c44ea4",
"assets/assets/images/eusilvio.png": "aee961c03c7977314f58dcd695e581de",
"assets/assets/images/004-b.webp": "b8ce422b20439269203b350e431e1109",
"assets/assets/images/006-b.webp": "362cf1aa190c813083268c4908d4e37f",
"assets/assets/images/005-a.png": "fc581a9c7d6eb0238305063bd8f6f1e2",
"assets/assets/images/009-a.png": "917458327cd97d01d6e8c5733f805136",
"assets/assets/images/016-b.webp": "9bfeb78e8087ccc1e1b25f7c5447e04d",
"assets/assets/images/021-b.webp": "1d9490af484c1154d3e98907fbfbeed9",
"assets/assets/images/002-a.png": "648ccec389e8876060c413fc8a78689a",
"assets/assets/images/graphic_design.png": "0253234547128b3fa60a397d8562b687",
"assets/assets/images/011-a.png": "1e1904b8798d3520e72d30127ddabf5b",
"assets/assets/images/012-a.png": "63f77de48817dd346ad1bafbcb3beadb",
"assets/assets/images/013-a.png": "56549e7655515fc8e6d153192ad1afe0",
"assets/assets/images/010-b.webp": "537704e154a6aec380558ef3710004e9",
"assets/assets/images/001-b.webp": "1a2d8729b5eb1fef298498b52a7549f3",
"assets/assets/images/017-b.webp": "9efdba3734b76735802ef4671abf634f",
"assets/assets/images/013-b.webp": "c0a6dffede30f3f8982ef4e9ab50798d",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "8fc870a6126e137310c6f4c2563d1ac9",
"assets/AssetManifest.bin": "a2a4ccb1ddc1ef7904271ddf23e80ad3",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"flutter_bootstrap.js": "fb9506fd2763df9bb6436488296b25f2",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"index.html": "8100b62ff678c4e1031ccf1c83cb7434",
"/": "8100b62ff678c4e1031ccf1c83cb7434"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
