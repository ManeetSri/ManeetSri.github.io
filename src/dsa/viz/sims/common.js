// Small helpers the simulators share: schema checks with readable messages, and number formatting for
// messages. Node-safe and pure.

export const isObject = (value) => value !== null && typeof value === 'object' && !Array.isArray(value);
export const isNumber = (value) => typeof value === 'number' && Number.isFinite(value);
export const isWhole = (value) => Number.isInteger(value);
export const isText = (value) => typeof value === 'string' && value.trim().length > 0;
export const quote = (value) => JSON.stringify(value) ?? String(value);

// A field list for messages: `a`, `b` and `c`
export const fieldList = (names) => names.map((name) => `\`${name}\``).join(', ');

// The first field of `object` that isn't in `allowed`, as a message, or null
export const unknownField = (object, allowed, where = '') => {
    const extra = Object.keys(object).filter((key) => !allowed.includes(key));
    if (extra.length === 0) return null;
    return `${where}unknown field${extra.length > 1 ? 's' : ''} ${fieldList(extra)} (allowed: ${fieldList(allowed)})`;
};

// Checks a number field; returns a message or null. `optional` lets undefined through.
export const checkNumber = (value, name, { min, above, max, whole = false, optional = false } = {}) => {
    if (value === undefined) return optional ? null : `\`${name}\` is missing`;
    if (!isNumber(value) || (whole && !isWhole(value))) return `\`${name}\` must be ${whole ? 'a whole number' : 'a number'}, not ${quote(value)}`;
    if (above !== undefined && !(value > above)) return `\`${name}\` must be more than ${above}, not ${value}`;
    if (min !== undefined && value < min) return `\`${name}\` must be at least ${min}, not ${value}`;
    if (max !== undefined && value > max) return `\`${name}\` must be at most ${max}, not ${value}`;
    return null;
};

export const checkTitle = (props) => (props.title === undefined || isText(props.title) ? null : '`title` must be text');

// Numbers in messages: at most `digits` decimals, no trailing zeros
export const num = (value, digits = 2) => {
    const rounded = Number(value.toFixed(digits));
    return Object.is(rounded, -0) ? '0' : String(rounded);
};
export const secs = (value, digits = 2) => `${num(value, digits)}s`;
export const pct = (part, whole) => (whole === 0 ? '0%' : `${Math.round((part / whole) * 100)}%`);
export const plural = (count, one, many = `${one}s`) => `${count} ${count === 1 ? one : many}`;

// "a", "a and b", "a, b and c"
export const listing = (items) => (items.length <= 1 ? items.join('') : `${items.slice(0, -1).join(', ')} and ${items.at(-1)}`);

const SUPERSCRIPTS = { 0: '⁰', 1: '¹', 2: '²', 3: '³', 4: '⁴', 5: '⁵', 6: '⁶', 7: '⁷', 8: '⁸', 9: '⁹', '-': '⁻' };
export const superscript = (value) => String(value).split('').map((char) => SUPERSCRIPTS[char] ?? char).join('');

// Axis ticks: a round step that gives about `count` ticks between 0 and `max`
export const tickStep = (max, count = 8) => {
    const raw = Math.max(max, 1e-9) / count;
    const power = 10 ** Math.floor(Math.log10(raw));
    const scaled = raw / power;
    return (scaled <= 1 ? 1 : scaled <= 2 ? 2 : scaled <= 2.5 ? 2.5 : scaled <= 5 ? 5 : 10) * power;
};
export const ticks = (max, count = 8) => {
    const step = tickStep(max, count);
    const values = [];
    for (let value = 0; value <= max + step * 1e-6; value += step) values.push(Number(value.toPrecision(10)));
    return values;
};

// Colours for owners (cache layers, ring nodes), in order; each has a hex for SVG and a matching swatch class
export const OWNER_COLOURS = ['#FDB03A', '#5DD8FF', '#30D158', '#FF7AB2', '#DABAFF', '#F05138', '#78C2B3', '#FFD60A'];
export const OK = '#30D158';
export const BAD = '#FF9D96';
export const SKY = '#5DD8FF';
export const AMBER = '#FDB03A';
