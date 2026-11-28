// Helpers for the scripted diagrams' schemas. A schema returns true, or the first problem it finds as a
// sentence the build prints after "```visual <name>: ".

class Problem extends Error {}

export const fail = (message) => {
    throw new Problem(message);
};

export const need = (condition, message) => {
    if (!condition) fail(message);
};

// Wraps a checker that calls fail(), so it returns true or the problem instead
export const schema = (check) => (props) => {
    try {
        check(props && typeof props === 'object' && !Array.isArray(props) ? props : {});
        return true;
    } catch (error) {
        if (error instanceof Problem) return error.message;
        throw error;
    }
};

export const isText = (value) => typeof value === 'string' && value.trim().length > 0;
export const isNumber = (value) => typeof value === 'number' && Number.isFinite(value);
export const isObject = (value) => Boolean(value) && typeof value === 'object' && !Array.isArray(value);
export const optionalText = (value) => value === undefined || value === null || typeof value === 'string' || typeof value === 'number';

// Ids appear in edge keys like `api->db`, so they're single words: letters, digits, _ . and -
const ID = /^[A-Za-z0-9_][\w.-]*$/;

export const quote = (value) => `\`${value}\``;
export const listOf = (ids, limit = 10) => {
    const shown = ids.slice(0, limit).map(quote).join(', ');
    return ids.length > limit ? `${shown} and ${ids.length - limit} more` : shown || 'none';
};

export const checkId = (value, where) => {
    need(value !== undefined && value !== null && value !== '', `${where} needs an \`id\``);
    need(typeof value === 'string', `${where} has id ${JSON.stringify(value)}: ids are words, so quote numbers ("${value}")`);
    need(ID.test(value) && !value.includes('->'), `${where} has id ${quote(value)}: use letters, digits, _ . or - (no spaces or ->)`);
};

// Checks a list of { id } entries: present, an array, ids valid and unique (across `taken` as well)
export const checkEntries = (list, name, { taken = new Set(), required = true } = {}) => {
    if (list === undefined || list === null) {
        need(!required, `needs \`${name}\`: a list`);
        return [];
    }
    need(Array.isArray(list), `\`${name}\` must be a list`);
    need(!required || list.length > 0, `\`${name}\` is empty`);
    list.forEach((entry, index) => {
        need(isObject(entry), `${name}[${index}] must be a mapping like { id: …, label: … }`);
        checkId(entry.id, `${name}[${index}]`);
        need(!taken.has(entry.id), `${name}[${index}]: the id ${quote(entry.id)} is used twice`);
        taken.add(entry.id);
        need(optionalText(entry.label), `${name}[${index}] (${quote(entry.id)}): \`label\` must be text`);
    });
    return list;
};

// A grid position [col, row] of non-negative numbers
export const checkAt = (at, where) => {
    need(Array.isArray(at) && at.length === 2 && at.every((value) => isNumber(value) && value >= 0), `${where} needs \`at: [col, row]\` with two numbers from 0 (got ${JSON.stringify(at)})`);
};

export const checkLine = (line, where) => {
    need(line === undefined || (Number.isInteger(line) && line > 0), `${where}: \`line\` must be a line number from 1`);
};

// Two grid rectangles ({ x, y, w, h }) overlap, with a little slack
export const overlaps = (a, b) => a.x < b.x + b.w - 1 && b.x < a.x + a.w - 1 && a.y < b.y + b.h - 1 && b.y < a.y + a.h - 1;
