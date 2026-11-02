const EVENT_NAME = 'contact-prefill';

// Starts the contact form's message for the visitor, and takes them to it
export const prefillContact = (message) => {
    window.dispatchEvent(new CustomEvent(EVENT_NAME, { detail: message }));
    document.getElementById('contact')?.scrollIntoView();
};

export const onContactPrefill = (listener) => {
    const handler = (event) => listener(event.detail);
    window.addEventListener(EVENT_NAME, handler);
    return () => window.removeEventListener(EVENT_NAME, handler);
};
