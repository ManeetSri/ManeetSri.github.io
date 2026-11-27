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
};

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
        case 'order': return null;
        case 'recall': return null;
        default: return String(question.answer);
    }
};
