const COOLDOWN_MS = 15000;

// Longer values are cut. Netlify can still receive anything sent directly, so this only protects
// honest visitors and the inbox. Spam filtering itself is done by Netlify.
export const FIELD_LIMITS = { name: 100, email: 254, message: 2000 };

const lastSentAt = new Map();

export class FormCooldownError extends Error {}

const clean = (data) => Object.fromEntries(
    Object.entries(data).map(([key, value]) => {
        const text = String(value).trim();
        return [key, FIELD_LIMITS[key] ? text.slice(0, FIELD_LIMITS[key]) : text.slice(0, 200)];
    }),
);

const encode = (data) => Object.keys(data)
    .map((key) => `${encodeURIComponent(key)}=${encodeURIComponent(data[key])}`)
    .join('&');

// Netlify Forms answers on the site root. fetch only rejects on network errors, so a failed
// status has to be turned into an error here.
export const submitNetlifyForm = async (formName, { 'bot-field': honeypot, ...data }) => {
    // Only bots fill in the hidden field. They're told it worked, and nothing is sent.
    if (honeypot) return;

    const previous = lastSentAt.get(formName);
    if (previous && Date.now() - previous < COOLDOWN_MS) {
        throw new FormCooldownError('Please wait before sending again');
    }

    const response = await fetch('/', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: encode({ 'form-name': formName, 'bot-field': '', ...clean(data) }),
    });
    if (!response.ok) {
        throw new Error(`Form submission failed with status ${response.status}`);
    }
    lastSentAt.set(formName, Date.now());
};
