// Every in-console URL for a course, built from its base path
export const makeLinks = (base) => ({
    base,
    today: base,
    path: `${base}/path`,
    lesson: (id) => `${base}/learn/${id}`,
    practice: `${base}/practice`,
    item: (id) => `${base}/practice/${id}`,
    review: `${base}/review`,
    mock: `${base}/mock`,
    progress: `${base}/progress`,
    notes: `${base}/notes`,
    settings: `${base}/settings`,
    sheets: `${base}/sheets`,
    sheet: (id) => `${base}/sheets/${id}`,
    checkpoint: (id) => `${base}/checkpoint/${id}`,
    start: `${base}/start`,
});
