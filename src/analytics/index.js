// Site-wide analytics. Firebase loads only after a visitor accepts cookies, and separately from the
// main bundle, so it never slows the first paint and an ad blocker stopping it can't break the site.
//
// Events never include what a visitor typed: only choices, counts and yes/no flags.

import { allowsAnalytics, getConsent, needsChoice, saveConsent } from './consent';

const MAX_VALUE_LENGTH = 100;
const MAX_QUEUED = 100;

let client = null;
let loading = false;
let queue = [];

// Local builds and Netlify deploy previews (their hostnames contain "--") stay out of the numbers
const isProductionSite = () => {
    const { hostname } = window.location;
    return import.meta.env.PROD && hostname !== 'localhost' && hostname !== '127.0.0.1' && !hostname.includes('--');
};

const cleanParams = (params) => Object.fromEntries(
    Object.entries(params).map(([key, value]) => [key, typeof value === 'string' ? value.slice(0, MAX_VALUE_LENGTH) : value]),
);

// Before a choice is made, events wait in memory. They're sent on accept and dropped on reject.
export const track = (name, params = {}) => {
    if (!isProductionSite()) return;
    const cleaned = cleanParams(params);
    if (allowsAnalytics() && client) {
        client.log(name, cleaned);
    } else if ((allowsAnalytics() || needsChoice()) && queue.length < MAX_QUEUED) {
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
        client = await createClient(getConsent());
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
    if (loading || !isProductionSite() || !allowsAnalytics()) return;
    loading = true;
    const schedule = window.requestIdleCallback ?? ((callback) => setTimeout(callback, 1200));
    schedule(load);
};

// Withdrawing consent also removes the cookies Google has already set
const clearGoogleCookies = () => {
    const parts = window.location.hostname.split('.');
    const domains = ['', window.location.hostname, ...parts.map((_, index) => `.${parts.slice(index).join('.')}`)];
    document.cookie.split(';')
        .map((cookie) => cookie.split('=')[0].trim())
        .filter((name) => /^(_ga|_gid|_gat|_gcl)/.test(name))
        .forEach((name) => {
            domains.forEach((domain) => {
                document.cookie = `${name}=; Max-Age=0; path=/${domain ? `; domain=${domain}` : ''}`;
            });
        });
};

export const applyConsent = (choice) => {
    const consent = saveConsent(choice);
    if (consent.analytics) {
        client?.setConsent(consent);
        client?.setEnabled(true);
        startAnalytics();
    } else {
        queue = [];
        client?.setConsent(consent);
        client?.setEnabled(false);
        clearGoogleCookies();
    }
    return consent;
};
