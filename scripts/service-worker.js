// The Vite plugin injects the paths and version of the current build.
const SHELL_PREFIX = 'maneet-pwa-shell-';
const SHELL_CACHE = SHELL_PREFIX + '__BUILD_VERSION__';
const RUNTIME_CACHE = 'maneet-pwa-assets-v1';
const SHELL_FILES = new Set(/* __SHELL_FILES__ */ []);
const CONSOLE_BASES = /* __CONSOLE_BASES__ */ [];
const PUBLIC_ROUTES = new Set(['/', '/index.html', '/projects', '/blogs', '/privacy', '/build']);
const ASSET_LIMIT = 180;
const BUILD_ASSET = /^\/assets\/(?:dsa\/)?[^/]+-[\w-]{8}\.(?:js|css|woff2|avif|jpe?g|png|webp|svg)$/;

self.addEventListener('install', (event) => {
    event.waitUntil(caches.open(SHELL_CACHE).then((cache) => cache.addAll(
        [...SHELL_FILES].map((url) => new Request(url, { cache: BUILD_ASSET.test(url) ? 'default' : 'reload' })),
    )));
});

self.addEventListener('activate', (event) => {
    event.waitUntil((async () => {
        const keys = await caches.keys();
        await Promise.all(keys.filter((key) => key.startsWith(SHELL_PREFIX) && key !== SHELL_CACHE)
            .map((key) => caches.delete(key)));
        await self.clients.claim();
    })());
});

const isConsolePath = (path) => CONSOLE_BASES.some((base) => path === base || path.startsWith(`${base}/`));
const fromShell = (path) => caches.match(path, { cacheName: SHELL_CACHE }).catch(() => undefined);

const navigate = async (request, isConsole) => {
    const response = await fetch(request).catch(() => undefined);
    if (response && response.status < 500) return response;

    const shell = await fromShell('/index.html');
    if (!shell) return response ?? Response.error();
    if (!isConsole) return shell;

    const headers = new Headers(shell.headers);
    headers.set('X-Robots-Tag', 'noindex, nofollow, noarchive');
    // The Fetch API decodes the body when constructing a new response.
    headers.delete('Content-Encoding');
    headers.delete('Content-Length');
    return new Response(shell.body, { headers });
};

// Serialise eviction across parallel chunk requests. Hashed files can be reused across deploys.
let cacheWrites = Promise.resolve();
const saveAsset = (request, response) => {
    cacheWrites = cacheWrites.then(async () => {
        const cache = await caches.open(RUNTIME_CACHE);
        await cache.put(request, response);
        const keys = await cache.keys();
        await Promise.all(keys.slice(0, Math.max(0, keys.length - ASSET_LIMIT)).map((key) => cache.delete(key)));
    }).catch(() => {});
    return cacheWrites;
};

const loadAsset = async (request, path) => {
    const cached = SHELL_FILES.has(path)
        ? await fromShell(request)
        : await caches.match(request, { cacheName: RUNTIME_CACHE }).catch(() => undefined);
    if (cached) return { response: cached };

    const response = await fetch(request);
    const contentType = response.headers.get('Content-Type') ?? '';
    const cacheable = BUILD_ASSET.test(path) && response.status === 200 && !response.redirected &&
        contentType && !contentType.includes('text/html') && !response.headers.get('Cache-Control')?.includes('no-store');
    return { response, saved: cacheable ? saveAsset(request, response.clone()) : undefined };
};

self.addEventListener('fetch', (event) => {
    const { request } = event;
    const url = new URL(request.url);
    if (request.method !== 'GET' || url.origin !== self.location.origin || request.headers.has('Range')) return;

    if (request.mode === 'navigate') {
        const path = url.pathname.replace(/\/+$/, '') || '/';
        const isConsole = isConsolePath(path);
        if (isConsole || PUBLIC_ROUTES.has(path)) event.respondWith(navigate(request, isConsole));
        return;
    }

    if (url.search || (!SHELL_FILES.has(url.pathname) && !BUILD_ASSET.test(url.pathname))) return;
    const asset = loadAsset(request, url.pathname);
    event.waitUntil(asset.then(({ saved }) => saved).catch(() => {}));
    event.respondWith(asset.then(({ response }) => response));
});
