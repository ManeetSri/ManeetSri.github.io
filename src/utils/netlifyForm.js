const encode = (data) => Object.keys(data)
    .map((key) => `${encodeURIComponent(key)}=${encodeURIComponent(data[key])}`)
    .join('&');

// Netlify Forms answers on the site root. fetch only rejects on network errors, so a failed
// status has to be turned into an error here.
export const submitNetlifyForm = async (formName, data) => {
    const response = await fetch('/', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: encode({ 'form-name': formName, ...data }),
    });
    if (!response.ok) {
        throw new Error(`Form submission failed with status ${response.status}`);
    }
};
