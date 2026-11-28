// A back-of-the-envelope calculator, for ```visual estimator.
// Props: { inputs: [{ id, label, min, max, step?, value, unit?, scale?: linear | log }],
//   outputs: [{ id, label, formula, unit?, format?: si | bytes | duration | number }] }.
// Formulas use the safe language in expr.js and may read input ids and the ids of outputs listed above them.
// The schema parses every formula at build time, so an unknown name, an unknown function or a forward
// reference fails the build.
import { checkNumber, checkTitle, isObject, isText, quote, unknownField } from './common.js';
import { ExprError, FUNCTION_NAMES, NAME_PATTERN, evaluate, namesIn, parse } from './expr.js';
import { FORMATS } from './format.js';

export const SCALES = ['linear', 'log'];
const LIMITS = { inputs: 12, outputs: 16 };
const INPUT_FIELDS = ['id', 'label', 'min', 'max', 'step', 'value', 'unit', 'scale'];
const OUTPUT_FIELDS = ['id', 'label', 'formula', 'unit', 'format'];
// A log slider has about this many positions per factor of ten: each step is about 10%, so values rounded to
// two significant figures still change on every arrow-key press
const STEPS_PER_DECADE = 24;

const checkId = (id, where, taken) => {
    if (!isText(id) || !NAME_PATTERN.test(id)) return `${where} needs an \`id\` made of letters, digits and _ (not starting with a digit), such as dailyUsers; got ${quote(id)}`;
    if (FUNCTION_NAMES.includes(id)) return `${where}: \`${id}\` is a function name; pick another id`;
    if (taken.includes(id)) return `${where}: the id \`${id}\` is already used`;
    return null;
};

const checkInput = (input, index, taken) => {
    const where = `inputs[${index}]`;
    if (!isObject(input)) return `${where} must be { id, label, min, max, value }`;
    const named = `${where}${isText(input.id) ? ` (${input.id})` : ''}`;
    const problem = unknownField(input, INPUT_FIELDS, `${named}: `) ?? checkId(input.id, where, taken)
        ?? (isText(input.label) ? null : `${named} needs a \`label\``)
        ?? checkNumber(input.min, 'min') ?? checkNumber(input.max, 'max')
        ?? (input.min < input.max ? null : `\`min\` (${input.min}) must be less than \`max\` (${input.max})`)
        ?? checkNumber(input.value, 'value', { min: input.min, max: input.max })
        ?? checkNumber(input.step, 'step', { above: 0, optional: true })
        ?? (input.unit === undefined || typeof input.unit === 'string' ? null : '`unit` must be text')
        ?? (input.scale === undefined || SCALES.includes(input.scale) ? null : `unknown \`scale\` ${quote(input.scale)}: use linear or log`)
        ?? (input.scale === 'log' && input.min <= 0 ? `a log scale needs \`min\` above 0, not ${input.min}` : null);
    if (problem) return problem.startsWith(where) ? problem : `${named}: ${problem}`;
    if (input.step !== undefined && input.scale !== 'log') {
        const steps = (input.value - input.min) / input.step;
        if (Math.abs(steps - Math.round(steps)) > 1e-6) return `${named}: \`value\` ${input.value} isn't a whole number of steps (${input.step}) from \`min\` ${input.min}, so the slider can't land on it`;
    }
    return null;
};

export const estimatorSchema = (props) => {
    if (!isObject(props)) return 'expected settings with `inputs` and `outputs`';
    const problem = unknownField(props, ['title', 'inputs', 'outputs']) ?? checkTitle(props);
    if (problem) return problem;
    const { inputs, outputs } = props;
    if (!Array.isArray(inputs) || inputs.length === 0) return '`inputs` must be a list of sliders, such as [{ id: users, label: Daily users, min: 1000, max: 100000000, value: 1000000, scale: log }]';
    if (inputs.length > LIMITS.inputs) return `\`inputs\` has ${inputs.length} sliders; keep it to ${LIMITS.inputs}`;
    const ids = [];
    for (const [index, input] of inputs.entries()) {
        const issue = checkInput(input, index, ids);
        if (issue) return issue;
        ids.push(input.id);
    }
    if (!Array.isArray(outputs) || outputs.length === 0) return '`outputs` must be a list of results, such as [{ id: qps, label: Requests per second, formula: users * 10 / 86400, format: si }]';
    if (outputs.length > LIMITS.outputs) return `\`outputs\` has ${outputs.length} results; keep it to ${LIMITS.outputs}`;
    const inputIds = [...ids];
    const outputIds = outputs.map((output) => (isObject(output) ? output.id : undefined));
    const scope = Object.fromEntries(inputs.map((input) => [input.id, input.value]));
    for (const [index, output] of outputs.entries()) {
        const where = `outputs[${index}]`;
        if (!isObject(output)) return `${where} must be { id, label, formula }`;
        const named = `${where}${isText(output.id) ? ` (${output.id})` : ''}`;
        const issue = unknownField(output, OUTPUT_FIELDS, `${named}: `) ?? checkId(output.id, where, ids)
            ?? (isText(output.label) ? null : `${named} needs a \`label\``)
            ?? (output.unit === undefined || typeof output.unit === 'string' ? null : `${named}: \`unit\` must be text`)
            ?? (output.format === undefined || FORMATS.includes(output.format) ? null : `${named}: unknown \`format\` ${quote(output.format)}: use si, bytes, duration or number`)
            ?? (output.formula === undefined ? `${named} needs a \`formula\`` : null);
        if (issue) return issue;
        let tree;
        try {
            tree = parse(output.formula);
        } catch (error) {
            if (error instanceof ExprError) return `${named}: the formula ${quote(String(output.formula))} doesn't parse: ${error.message}`;
            throw error;
        }
        for (const name of namesIn(tree)) {
            if (ids.includes(name)) continue;
            const later = outputIds.indexOf(name);
            if (later > index) return `${named}: the formula uses \`${name}\`, which is worked out by a later output (outputs[${later}]); move ${output.id} below it`;
            if (later === index) return `${named}: the formula uses its own id \`${name}\``;
            const known = [inputIds.length ? `inputs: ${inputIds.join(', ')}` : null, ids.length > inputIds.length ? `earlier outputs: ${ids.slice(inputIds.length).join(', ')}` : null].filter(Boolean).join('; ');
            return `${named}: unknown name \`${name}\` in the formula (${known})`;
        }
        const value = evaluate(tree, scope);
        if (!Number.isFinite(value)) return `${named}: the formula gives ${value} at the starting values; check for a division by zero or a huge power`;
        scope[output.id] = value;
        ids.push(output.id);
    }
    return true;
};

// Compiles every formula once; the result works out all outputs for a map of input values
export const compileEstimator = (outputs) => {
    const trees = outputs.map((output) => ({ id: output.id, tree: parse(output.formula) }));
    return (values) => {
        const scope = { ...values };
        return trees.map(({ id, tree }) => {
            let value;
            try {
                value = evaluate(tree, scope);
            } catch {
                value = NaN;
            }
            scope[id] = value;
            return { id, value };
        });
    };
};

// Two significant figures, for log sliders, so 3,162,278 shows as 3,200,000
const roundSignificant = (value, digits = 2) => (value === 0 ? 0 : Number(value.toPrecision(digits)));

const snap = (value, input) => {
    let result = value;
    if (input.step) result = input.min + Math.round((result - input.min) / input.step) * input.step;
    result = Number(result.toPrecision(12));
    return Math.min(input.max, Math.max(input.min, result));
};

// How many positions a log slider has
export const logSteps = (input) => Math.max(STEPS_PER_DECADE, Math.round(Math.log10(input.max / input.min) * STEPS_PER_DECADE));

// A slider's position for a value, and back. Linear sliders use the value itself. The view keeps a log
// slider's position as well as its value, so a step never rounds back to where it started.
export const positionOf = (input, value) => {
    if (input.scale !== 'log') return value;
    return Math.round((Math.log(value / input.min) / Math.log(input.max / input.min)) * logSteps(input));
};
export const valueAt = (input, position) => {
    if (input.scale !== 'log') return snap(position, input);
    const steps = logSteps(input);
    if (position <= 0) return input.min;
    if (position >= steps) return input.max;
    const raw = input.min * (input.max / input.min) ** (position / steps);
    return snap(roundSignificant(raw), input);
};
