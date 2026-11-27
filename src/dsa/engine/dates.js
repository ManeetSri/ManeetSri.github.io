// Days are local calendar days, so "today" matches the learner's clock, not UTC
export const DAY_MS = 86_400_000;

const pad = (value) => String(value).padStart(2, '0');

export const dayKey = (ms) => {
    const date = new Date(ms);
    return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}`;
};

export const startOfDay = (ms) => {
    const date = new Date(ms);
    date.setHours(0, 0, 0, 0);
    return date.getTime();
};

export const endOfDay = (ms) => startOfDay(ms) + DAY_MS - 1;

// Moves by calendar days, so daylight-saving changes don't skip or repeat a day
export const addDays = (ms, days) => {
    const date = new Date(ms);
    date.setDate(date.getDate() + days);
    return date.getTime();
};

export const isSameDay = (a, b) => dayKey(a) === dayKey(b);
