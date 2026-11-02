// The visitor's cookie choice. Nothing from Google loads until they accept.
const STORAGE_KEY = 'maneet-cookie-consent';
const MAX_AGE_MS = 365 * 24 * 60 * 60 * 1000;
const OPEN_EVENT = 'cookie-settings-open';

const read = () => {
    try {
        const saved = JSON.parse(localStorage.getItem(STORAGE_KEY));
        return saved && Date.now() - saved.at < MAX_AGE_MS ? saved : null;
    } catch {
        return null;
    }
};

let current = read();

export const getConsent = () => current;

// The browser's Global Privacy Control signal is treated as an answer of "no"
const hasPrivacySignal = () => Boolean(navigator.globalPrivacyControl);

export const needsChoice = () => !current && !hasPrivacySignal();

export const allowsAnalytics = () => current?.analytics === true;

export const saveConsent = ({ analytics, ads }) => {
    // Ads measurement runs through Analytics, so it can't be on by itself
    current = { analytics: analytics || ads, ads, at: Date.now() };
    try {
        localStorage.setItem(STORAGE_KEY, JSON.stringify(current));
    } catch {
        // Without storage the choice lasts until the page is closed
    }
    return current;
};

export const openCookieSettings = () => window.dispatchEvent(new Event(OPEN_EVENT));

export const onOpenCookieSettings = (listener) => {
    window.addEventListener(OPEN_EVENT, listener);
    return () => window.removeEventListener(OPEN_EVENT, listener);
};
