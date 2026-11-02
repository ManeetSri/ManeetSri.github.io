// Site-wide analytics. Firebase loads separately after the page is idle, so it never slows the
// first paint, and an ad blocker stopping it can't break the site.
//
// Events never include what a visitor typed: only choices, counts and yes/no flags.

const OPT_OUT_KEY = 'maneet-analytics-off';
const MAX_VALUE_LENGTH = 100;
const MAX_QUEUED = 100;

let client = null;
let started = false;
let queue = [];

const hasOptedOut = () => {
    try {
        return localStorage.getItem(OPT_OUT_KEY) === '1';
    } catch {
        return false;
    }
};

// The browser's Global Privacy Control signal counts as opting out
const privacySignal = () => Boolean(navigator.globalPrivacyControl);

// Local builds and Netlify deploy previews (their hostnames contain "--") stay out of the numbers
const isProductionSite = () => {
    const { hostname } = window.location;
    return import.meta.env.PROD && hostname !== 'localhost' && hostname !== '127.0.0.1' && !hostname.includes('--');
};

export const isAnalyticsOn = () => !hasOptedOut() && !privacySignal();

const cleanParams = (params) => Object.fromEntries(
    Object.entries(params).map(([key, value]) => [key, typeof value === 'string' ? value.slice(0, MAX_VALUE_LENGTH) : value]),
);

export const track = (name, params = {}) => {
    if (!isProductionSite() || !isAnalyticsOn()) return;
    const cleaned = cleanParams(params);
    if (client) {
        client.log(name, cleaned);
    } else if (queue.length < MAX_QUEUED) {
        queue.push([name, cleaned]);
    }
};

const viewportClass = () => {
    if (window.innerWidth < 768) return 'phone';
    return window.innerWidth < 1024 ? 'tablet' : 'desktop';
};

const load = async () => {
    try {
        const { createClient } = await import('./firebase');
        client = await createClient();
        if (!client) return;
        client.setUserProperties({
            viewport_class: viewportClass(),
            reduced_motion: String(window.matchMedia('(prefers-reduced-motion: reduce)').matches),
        });
        queue.forEach(([name, params]) => client.log(name, params));
    } catch (error) {
        console.warn('Analytics unavailable:', error);
    } finally {
        queue = [];
    }
};

export const startAnalytics = () => {
    if (started || !isProductionSite() || !isAnalyticsOn()) return;
    started = true;
    const schedule = window.requestIdleCallback ?? ((callback) => setTimeout(callback, 1200));
    schedule(load);
};

export const setAnalyticsOn = (on) => {
    try {
        if (on) {
            localStorage.removeItem(OPT_OUT_KEY);
        } else {
            localStorage.setItem(OPT_OUT_KEY, '1');
        }
    } catch {
        // Without storage the choice lasts until the page is closed
    }
    if (on) {
        client?.setEnabled(true);
        startAnalytics();
    } else {
        queue = [];
        client?.setEnabled(false);
    }
};
