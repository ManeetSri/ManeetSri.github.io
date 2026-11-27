// Development only: keeps progress in this browser's localStorage, so the console can be built and
// checked without signing in. Production builds never include it.
const KEY = 'maneet-dsa-dev';
const MODE_KEY = 'maneet-dsa-dev-mode';

export const rememberLocalMode = (on) => {
    try {
        if (on) sessionStorage.setItem(MODE_KEY, '1');
        else sessionStorage.removeItem(MODE_KEY);
    } catch {
        // Session storage is blocked: local mode just won't survive a reload
    }
};

export const isLocalModeRemembered = () => {
    try {
        return sessionStorage.getItem(MODE_KEY) === '1';
    } catch {
        return false;
    }
};

const isPlainObject = (value) => value !== null && typeof value === 'object' && !Array.isArray(value);

// Matches Firestore's merge: nested maps combine, everything else is replaced
const merge = (target = {}, patch) => Object.fromEntries([
    ...Object.entries(target),
    ...Object.entries(patch).map(([key, value]) => [key, isPlainObject(value) && isPlainObject(target[key]) ? merge(target[key], value) : value]),
]);

const read = () => {
    try {
        return JSON.parse(localStorage.getItem(KEY)) ?? {};
    } catch {
        return {};
    }
};

export const createLocalAdapter = () => {
    let data = read();
    const listeners = new Map();

    const save = (name) => {
        try {
            localStorage.setItem(KEY, JSON.stringify(data));
        } catch {
            // Storage is full or blocked: progress lasts until the tab closes
        }
        (listeners.get(name) ?? []).forEach((listener) => listener({ ...(data[name] ?? {}) }));
    };

    return {
        subscribe: (name, callback) => {
            if (!listeners.has(name)) listeners.set(name, new Set());
            listeners.get(name).add(callback);
            queueMicrotask(() => callback({ ...(data[name] ?? {}) }));
            return () => listeners.get(name).delete(callback);
        },
        put: async (name, id, patch) => {
            data = { ...data, [name]: { ...(data[name] ?? {}), [id]: merge(data[name]?.[id], patch) } };
            save(name);
        },
        remove: async (name, id) => {
            const { [id]: _removed, ...rest } = data[name] ?? {};
            data = { ...data, [name]: rest };
            save(name);
        },
        onStatus: (listener) => {
            listener('local');
            return () => {};
        },
        destroy: () => {},
    };
};
