// How each question type is answered, checked and explained. Pure functions, shared by lessons and the
// review queue.

export const BIG_O_OPTIONS = ['O(1)', 'O(log n)', 'O(n)', 'O(n log n)', 'O(n²)', 'O(2ⁿ)'];

export const TYPE_LABELS = {
    mcq: 'Choose one',
    multi: 'Choose all that apply',
    truefalse: 'True or false',
    output: 'Predict the output',
    trace: 'Trace the state',
    blank: 'Fill in the blanks',
    order: 'Put the lines in order',
    bigo: 'Pick the Big-O',
    bug: 'Spot the bug',
    match: 'Match the pairs',
    recall: 'Explain it',
    estimate: 'Estimate it',
    sort: 'Sort into groups',
};

// An estimate as people write it: 2500, 2,500, 2.5k, 3M, 1.2e6. Null when it isn't a number.
const SUFFIXES = { k: 1e3, m: 1e6, b: 1e9, g: 1e9, t: 1e12 };
export const parseEstimate = (text) => {
    const match = String(text ?? '').trim().replace(/[,_\s]/g, '').match(/^(-?\d*\.?\d+(?:e[+-]?\d+)?)([kmbgt])?$/i);
    if (!match) return null;
    const value = Number(match[1]) * (match[2] ? SUFFIXES[match[2].toLowerCase()] : 1);
    return Number.isFinite(value) ? value : null;
};

// The accepted range for an estimate: within a factor (default 2) or a percentage of the answer
export const estimateRange = (question) => {
    const { answer, within = {} } = question;
    if (within.percent !== undefined) return [answer * (1 - within.percent / 100), answer * (1 + within.percent / 100)];
    const factor = within.factor ?? 2;
    return [answer / factor, answer * factor];
};

const formatNumber = (value) => (Math.abs(value) >= 1e5 || (Math.abs(value) < 0.01 && value !== 0) ? value.toExponential(1) : Number(value.toPrecision(3)).toLocaleString('en-GB'));

// Same order every time for the same question, so a page reload doesn't reshuffle
const seeded = (text) => {
    let hash = 2166136261;
    for (const character of text) hash = Math.imul(hash ^ character.charCodeAt(0), 16777619);
    return () => {
        hash = Math.imul(hash ^ (hash >>> 15), 2246822507);
        hash = Math.imul(hash ^ (hash >>> 13), 3266489909);
        hash ^= hash >>> 16;
        return (hash >>> 0) / 4294967296;
    };
};

export const shuffledIndexes = (length, seed) => {
    const random = seeded(seed);
    const order = Array.from({ length }, (_, index) => index);
    for (let index = length - 1; index > 0; index -= 1) {
        const swap = Math.floor(random() * (index + 1));
        [order[index], order[swap]] = [order[swap], order[index]];
    }
    // A puzzle that starts solved isn't a puzzle
    if (length > 1 && order.every((value, index) => value === index)) [order[0], order[1]] = [order[1], order[0]];
    return order;
};

export const blankCount = (code) => (code.match(/___/g) ?? []).length;

export const emptyAnswer = (question) => {
    switch (question.type) {
        case 'multi': return [];
        case 'output':
        case 'trace': return '';
        case 'blank': return Array(blankCount(question.code)).fill('');
        case 'order': return shuffledIndexes(question.lines.length, question.id);
        case 'match': return Array(question.pairs.length).fill(-1);
        case 'estimate': return '';
        case 'sort': return Array(question.items.length).fill(-1);
        default: return null;
    }
};

export const isAnswered = (question, answer) => {
    switch (question.type) {
        case 'multi': return answer.length > 0;
        case 'output':
        case 'trace': return answer.trim().length > 0;
        case 'blank': return answer.every((value) => value.trim().length > 0);
        case 'order': return true;
        case 'match': return answer.every((value) => value >= 0);
        case 'estimate': return parseEstimate(answer) !== null;
        case 'sort': return answer.every((value) => value >= 0);
        case 'recall': return answer !== null;
        default: return answer !== null;
    }
};

const outputForm = (text) => text.replace(/\r/g, '').split('\n').map((line) => line.trimEnd()).join('\n').trim();
const traceForm = (text) => text.replace(/\s+/g, '');
const accepted = (expected) => (Array.isArray(expected) ? expected : [expected]);

export const isCorrect = (question, answer) => {
    switch (question.type) {
        case 'multi': return answer.length === question.answer.length && question.answer.every((index) => answer.includes(index));
        case 'output': return [question.answer, ...(question.accept ?? [])].some((expected) => outputForm(expected) === outputForm(answer));
        case 'trace': return [question.answer, ...(question.accept ?? [])].some((expected) => traceForm(expected) === traceForm(answer));
        case 'blank': return question.answers.every((expected, index) => accepted(expected).some((value) => value.trim() === answer[index].trim()));
        case 'order': return answer.every((value, index) => value === index);
        case 'match': return answer.every((value, index) => value === index);
        case 'estimate': {
            const value = parseEstimate(answer);
            const [low, high] = estimateRange(question);
            return value !== null && value >= low && value <= high;
        }
        case 'sort': return question.items.every(([, bucket], index) => answer[index] === bucket);
        case 'recall': return answer === true;
        default: return answer === question.answer;
    }
};

// The right answer, in words, for the feedback after a wrong attempt
export const correctAnswerText = (question) => {
    switch (question.type) {
        case 'mcq': return question.options[question.answer];
        case 'multi': return question.answer.map((index) => question.options[index]).join(' · ');
        case 'truefalse': return question.answer ? 'True' : 'False';
        case 'blank': return question.answers.map((expected) => accepted(expected)[0]).join(' · ');
        case 'bug': return `Line ${question.answer}`;
        case 'match': return question.pairs.map(([left, right]) => `${left} → ${right}`).join(' · ');
        case 'output':
        case 'trace': return question.answer;
        case 'estimate': {
            const [low, high] = estimateRange(question);
            const unit = question.unit ? ` ${question.unit}` : '';
            return `About ${formatNumber(question.answer)}${unit} (anything from ${formatNumber(low)} to ${formatNumber(high)} counts)`;
        }
        case 'sort': return question.buckets.map((bucket, index) => `${bucket}: ${question.items.filter(([, at]) => at === index).map(([text]) => text).join(', ')}`).join(' · ');
        case 'order': return null;
        case 'recall': return null;
        default: return String(question.answer);
    }
};
