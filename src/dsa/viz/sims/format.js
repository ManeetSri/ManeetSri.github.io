// Number formats for the estimator's outputs: si (1.2k, 3.4M, 5B, 7T: counts, so a billion is B rather than G,
// and anything from 10¹⁵ up is written as × 10ⁿ), bytes (KB, MB, GB, TB, PB, base 1000), duration (seconds in,
// shown as µs, ms, s, min, h, days or years) and number (grouped digits). Three significant figures.

import { superscript } from './common.js';

export const FORMATS = ['si', 'bytes', 'duration', 'number'];

const special = (value) => (Number.isNaN(value) ? '—' : value === Infinity ? '∞' : value === -Infinity ? '−∞' : null);

// Three significant figures, without trailing zeros or exponent notation
export const significant = (value, digits = 3) => {
    if (value === 0) return '0';
    const rounded = Number(value.toPrecision(digits));
    const decimals = Math.max(0, digits - 1 - Math.floor(Math.log10(Math.abs(rounded))));
    return String(Number(rounded.toFixed(Math.min(decimals, 20))));
};

const scaled = (value, units, step) => {
    const sign = value < 0 ? '−' : '';
    const size = Math.abs(value);
    if (size < 1) return { text: `${sign}${significant(size)}`, unit: units[0] };
    // Round first, so 999,950 becomes 1M rather than 1000k
    const rounded = Number(size.toPrecision(3));
    const power = Math.min(units.length - 1, Math.floor(Math.log10(rounded) / Math.log10(step)));
    return { text: `${sign}${significant(rounded / step ** power)}`, unit: units[power] };
};

const SI = ['', 'k', 'M', 'B', 'T'];
const BYTES = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB'];
const DURATIONS = [
    { unit: 'µs', size: 1e-6 },
    { unit: 'ms', size: 1e-3 },
    { unit: 's', size: 1 },
    { unit: 'min', size: 60 },
    { unit: 'h', size: 3600 },
    { unit: 'days', size: 86400 },
    { unit: 'years', size: 86400 * 365 },
];

export const formatValue = (value, format = 'number') => {
    const odd = special(value);
    if (odd) return odd;
    if (format === 'si') {
        const rounded = Math.abs(Number(value.toPrecision(3)));
        if (rounded >= 1e15) {
            const power = Math.floor(Math.log10(rounded));
            return `${value < 0 ? '−' : ''}${significant(rounded / 10 ** power)} × 10${superscript(power)}`;
        }
        const { text, unit } = scaled(value, SI, 1000);
        return `${text}${unit}`;
    }
    if (format === 'bytes') {
        const { text, unit } = scaled(value, BYTES, 1000);
        return `${text} ${unit}`;
    }
    if (format === 'duration') {
        if (value === 0) return '0 s';
        const sign = value < 0 ? '−' : '';
        const size = Number(Math.abs(value).toPrecision(3));
        const chosen = [...DURATIONS].reverse().find((entry) => size >= entry.size) ?? DURATIONS[0];
        return `${sign}${significant(size / chosen.size)} ${chosen.unit}`;
    }
    const size = Math.abs(value);
    const text = size >= 1 || size === 0
        ? size.toLocaleString('en-GB', { maximumFractionDigits: 2 })
        : significant(size);
    return `${value < 0 ? '−' : ''}${text}`;
};

// A value with its unit; a unit starting with "/" attaches without a space (12 GB/day)
export const withUnit = (text, unit) => (unit ? `${text}${unit.startsWith('/') ? '' : ' '}${unit}` : text);
