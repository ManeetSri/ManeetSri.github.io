// Build-time plugin for the learning console's MDX content.
//
// Fenced blocks become components with their data parsed and checked here, so a malformed quiz fails
// the build with its file and line, and no YAML parser ever ships to the browser:
//
//   ```quiz            → <Quiz data="…">        YAML list of questions (see QUESTION_RULES)
//   ```cards           → <Takeaways data="…">   YAML list of { id, front, back } flashcards
//   ```visual <name>   → <Visual data="…">      optional YAML props for the visualiser
//   ```workspace       (design exercises and reviews) the answer template: { template, omit?, minutes? }
//   ```rubric          (design exercises) the criteria: [{ id, label, skill, look_for: [...] }]
//   ```findings        (architecture reviews) what a review should find: [{ id, title, severity, detail, lines? }]
//   ```swift title="…" → <CodeBlock data="…">   any other fence, with an ```output block after it attached
//
// A lesson's ```swift block marked `run` is a complete program. `npm run dsa:examples` (or design:examples)
// copies it to <package>/Examples/<module>/<lesson>-<n>.swift and can check that it prints exactly its
// ```output block. A block marked `check` (or `check ios`) is a fragment that's type-checked instead.
//
// Each file also exports `dsa`, a JSON string of its quiz questions, cards and section headings (and for
// design exercises its workspace, rubric and findings), which pages read without rendering the file.

import { parse } from 'yaml';
import { visit } from 'unist-util-visit';
import { BIG_O_OPTIONS } from '../src/dsa/mdx/quiz/grading.js';
import { VISUAL_NAMES } from '../src/dsa/viz/names.js';
import { VISUAL_SCHEMAS } from '../src/dsa/viz/schemas.js';
import { exampleFile, lessonLocation, parseMeta } from './dsa-content-lib.js';
import { SKILLS } from '../src/dsa/design/data/skills.js';
import { TEMPLATES, templateSections } from '../src/dsa/design/data/templates.js';

const isString = (value) => typeof value === 'string' && value.trim().length > 0;
const isStringList = (value, min) => Array.isArray(value) && value.length >= min && value.every(isString);
const isIndex = (value, list) => Number.isInteger(value) && value >= 0 && value < list.length;
const blanksIn = (code) => (code.match(/___/g) ?? []).length;

// What each question type needs, beyond the id, type and prompt every question has
const QUESTION_RULES = {
    mcq: (q) => (isStringList(q.options, 2) ? isIndex(q.answer, q.options) || 'answer must be the index of an option' : 'needs 2+ options'),
    multi: (q) => (isStringList(q.options, 2)
        ? (Array.isArray(q.answer) && q.answer.length > 0 && q.answer.every((index) => isIndex(index, q.options))) || 'answer must be a list of option indexes'
        : 'needs 2+ options'),
    truefalse: (q) => typeof q.answer === 'boolean' || 'answer must be true or false',
    output: (q) => (isString(q.code) ? typeof q.answer === 'string' || 'answer must be the exact output as a string' : 'needs code'),
    trace: (q) => typeof q.answer === 'string' || 'answer must be a string',
    blank: (q) => {
        if (!isString(q.code) || blanksIn(q.code) === 0) return 'needs code with ___ for each blank';
        const valid = Array.isArray(q.answers) && q.answers.length === blanksIn(q.code)
            && q.answers.every((answer) => isString(answer) || isStringList(answer, 1));
        return valid || `answers must list one answer (or a list of accepted answers) for each of the ${blanksIn(q.code)} blanks`;
    },
    order: (q) => isStringList(q.lines, 3) || 'needs 3+ lines, in the correct order',
    bigo: (q) => (q.options ?? BIG_O_OPTIONS).includes(q.answer) || `answer must be one of ${(q.options ?? BIG_O_OPTIONS).join(', ')}`,
    bug: (q) => (isString(q.code)
        ? (Number.isInteger(q.answer) && q.answer >= 1 && q.answer <= q.code.trimEnd().split('\n').length) || 'answer must be the 1-based number of the faulty line'
        : 'needs code'),
    match: (q) => (Array.isArray(q.pairs) && q.pairs.length >= 2 && q.pairs.every((pair) => isStringList(pair, 2) && pair.length === 2))
        || 'needs 2+ pairs, each [left, right]',
    recall: (q) => isString(q.model) || 'needs a model answer',
    estimate: (q) => {
        if (typeof q.answer !== 'number' || !(q.answer > 0)) return 'answer must be a positive number';
        if (q.unit !== undefined && !isString(q.unit)) return 'unit must be text';
        const within = q.within ?? {};
        if (within.factor !== undefined && !(within.factor > 1)) return 'within.factor must be more than 1';
        if (within.percent !== undefined && !(within.percent > 0 && within.percent < 100)) return 'within.percent must be between 0 and 100';
        return true;
    },
    sort: (q) => {
        if (!isStringList(q.buckets, 2) || q.buckets.length > 5) return 'needs 2 to 5 buckets';
        const valid = Array.isArray(q.items) && q.items.length >= 3
            && q.items.every((item) => Array.isArray(item) && item.length === 2 && isString(item[0]) && isIndex(item[1], q.buckets));
        return valid || 'needs 3+ items, each [text, bucket index]';
    },
};

const checkQuestion = (question, seen) => {
    if (!question || typeof question !== 'object') return 'each question must be a mapping';
    if (!isString(question.id)) return 'every question needs an id';
    if (seen.has(question.id)) return `duplicate question id "${question.id}"`;
    seen.add(question.id);
    const rule = QUESTION_RULES[question.type];
    if (!rule) return `question "${question.id}" has unknown type "${question.type}" (use ${Object.keys(QUESTION_RULES).join(', ')})`;
    if (!isString(question.prompt)) return `question "${question.id}" needs a prompt`;
    if (question.type !== 'recall' && !isString(question.explain)) return `question "${question.id}" needs an explanation`;
    const verdict = rule(question);
    return verdict === true ? null : `question "${question.id}": ${verdict}`;
};

const checkCard = (card, seen) => {
    if (!card || !isString(card.id) || !isString(card.front) || !isString(card.back)) return 'each card needs an id, front and back';
    if (seen.has(card.id)) return `duplicate card id "${card.id}"`;
    seen.add(card.id);
    return null;
};

const SEVERITIES = ['high', 'medium', 'low'];

const checkWorkspace = (value) => {
    if (!value || typeof value !== 'object' || Array.isArray(value)) return 'must be a mapping with a template';
    if (!TEMPLATES[value.template]) return `unknown template "${value.template}" (use ${Object.keys(TEMPLATES).join(', ')})`;
    const ids = TEMPLATES[value.template].sections.map((item) => item.id);
    const omit = value.omit ?? [];
    if (!Array.isArray(omit) || omit.some((id) => !ids.includes(id))) return `omit lists sections of the ${value.template} template: ${ids.join(', ')}`;
    if (value.minutes !== undefined && !(Number.isInteger(value.minutes) && value.minutes > 0)) return 'minutes must be a whole number';
    return null;
};

const checkCriterion = (criterion, seen) => {
    if (!criterion || !isString(criterion.id) || !isString(criterion.label)) return 'each criterion needs an id and a label';
    if (seen.has(criterion.id)) return `duplicate criterion id "${criterion.id}"`;
    seen.add(criterion.id);
    if (!SKILLS[criterion.skill]) return `criterion "${criterion.id}" has unknown skill "${criterion.skill}" (use ${Object.keys(SKILLS).join(', ')})`;
    if (!isStringList(criterion.look_for, 1)) return `criterion "${criterion.id}" needs look_for: what a strong answer covers`;
    return null;
};

const checkFinding = (finding, seen) => {
    if (!finding || !isString(finding.id) || !isString(finding.title) || !isString(finding.detail)) return 'each finding needs an id, title and detail';
    if (seen.has(finding.id)) return `duplicate finding id "${finding.id}"`;
    seen.add(finding.id);
    if (!SEVERITIES.includes(finding.severity)) return `finding "${finding.id}" needs a severity: ${SEVERITIES.join(', ')}`;
    if (finding.lines !== undefined && !/^\d+(-\d+)?(, *\d+(-\d+)?)*$/.test(String(finding.lines))) return `finding "${finding.id}" lines must look like 12, 12-18 or 12-18, 40`;
    return null;
};

const attributeOf = (node, name) => node.attributes?.find((attribute) => attribute.name === name)?.value;

const parseLines = (spec) => (spec ?? '').split(',').filter(Boolean).flatMap((part) => {
    const [from, to = from] = part.split('-').map(Number);
    return Array.from({ length: to - from + 1 }, (_, index) => from + index);
});

const textOf = (node) => (node.value ?? '') + (node.children ?? []).map(textOf).join('');

// Matches slugify() in src/dsa/mdx/slug.js, which gives each heading its id
const slugify = (text) => text.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');

const element = (name, payload) => ({
    type: 'mdxJsxFlowElement',
    name,
    children: [],
    attributes: [{ type: 'mdxJsxAttribute', name: 'data', value: JSON.stringify(payload) }],
    data: { payload },
});

// export const dsa = '<json>', built as an ESTree program because MDX compiles ESM from that tree
const exportNode = (value) => ({
    type: 'mdxjsEsm',
    value: '',
    data: {
        estree: {
            type: 'Program',
            sourceType: 'module',
            body: [{
                type: 'ExportNamedDeclaration',
                specifiers: [],
                source: null,
                declaration: {
                    type: 'VariableDeclaration',
                    kind: 'const',
                    declarations: [{
                        type: 'VariableDeclarator',
                        id: { type: 'Identifier', name: 'dsa' },
                        init: { type: 'Literal', value: JSON.stringify(value) },
                    }],
                },
            }],
        },
    },
});

const parseYaml = (node, file) => {
    try {
        return parse(node.value) ?? null;
    } catch (error) {
        return file.fail(`Invalid YAML in \`\`\`${node.lang} block: ${error.message}`, node);
    }
};

export default function remarkDsaBlocks() {
    return (tree, file) => {
        const questions = [];
        const cards = [];
        const questionIds = new Set();
        const cardIds = new Set();
        const headings = [];
        const location = lessonLocation(file.path);
        const runnable = [];
        const path = String(file.path ?? '').replaceAll('\\', '/');
        const isDesign = path.includes('/content/designs/');
        const isCritique = path.includes('/content/critiques/');
        let workspace = null;
        let rubric = null;
        let findings = null;

        visit(tree, 'heading', (node) => {
            if (node.depth !== 2) return;
            const text = textOf(node);
            headings.push({ id: slugify(text), text });
        });

        visit(tree, 'code', (node, index, parent) => {
            const replace = (replacement) => {
                parent.children[index] = replacement;
            };

            if (node.lang === 'quiz') {
                const list = parseYaml(node, file);
                if (!Array.isArray(list) || list.length === 0) file.fail('A ```quiz block must be a YAML list of questions', node);
                list.forEach((question) => {
                    const problem = checkQuestion(question, questionIds);
                    if (problem) file.fail(problem, node);
                });
                questions.push(...list);
                replace(element('Quiz', { questions: list }));
                return;
            }

            if (node.lang === 'cards') {
                const list = parseYaml(node, file);
                if (!Array.isArray(list) || list.length === 0) file.fail('A ```cards block must be a YAML list of cards', node);
                list.forEach((card) => {
                    const problem = checkCard(card, cardIds);
                    if (problem) file.fail(problem, node);
                });
                cards.push(...list);
                replace(element('Takeaways', { cards: list }));
                return;
            }

            if (node.lang === 'workspace' || node.lang === 'rubric' || node.lang === 'findings') {
                if (!isDesign && !isCritique) file.fail(`A \`\`\`${node.lang} block belongs in a design exercise or architecture review`, node);
                const value = parseYaml(node, file);
                if (node.lang === 'workspace') {
                    const problem = checkWorkspace(value);
                    if (problem) file.fail(`\`\`\`workspace: ${problem}`, node);
                    workspace = { template: value.template, minutes: value.minutes ?? TEMPLATES[value.template].minutes, sections: templateSections(value.template, value.omit) };
                } else if (node.lang === 'rubric') {
                    if (!Array.isArray(value) || value.length < 3) file.fail('A ```rubric block must list 3 or more criteria', node);
                    const seen = new Set();
                    value.forEach((criterion) => {
                        const problem = checkCriterion(criterion, seen);
                        if (problem) file.fail(`\`\`\`rubric: ${problem}`, node);
                    });
                    rubric = value;
                } else {
                    if (!Array.isArray(value) || value.length < 2) file.fail('A ```findings block must list 2 or more findings', node);
                    const seen = new Set();
                    value.forEach((finding) => {
                        const problem = checkFinding(finding, seen);
                        if (problem) file.fail(`\`\`\`findings: ${problem}`, node);
                    });
                    findings = value.map((finding) => ({ ...finding, lines: finding.lines === undefined ? undefined : String(finding.lines) }));
                }
                parent.children.splice(index, 1);
                return index;
            }

            if (node.lang === 'visual') {
                const name = node.meta?.trim();
                if (!VISUAL_NAMES.includes(name)) file.fail(`Unknown visualiser "${name}" (known: ${VISUAL_NAMES.join(', ')})`, node);
                const props = parseYaml(node, file) ?? {};
                const verdict = VISUAL_SCHEMAS[name]?.(props);
                if (verdict !== undefined && verdict !== true) file.fail(`\`\`\`visual ${name}: ${verdict}`, node);
                replace(element('Visual', { name, props }));
                return;
            }

            // An output block right after a code block becomes that block's output panel
            const previous = parent.children[index - 1];
            if (node.lang === 'output' && previous?.name === 'CodeBlock' && previous.data?.payload) {
                previous.data.payload.output = node.value;
                previous.attributes[0].value = JSON.stringify(previous.data.payload);
                parent.children.splice(index, 1);
                return index;
            }

            const meta = parseMeta(node.meta);
            if (meta.run && (node.lang !== 'swift' || !location)) file.fail('Only ```swift blocks in lessons can be marked `run`', node);
            if (meta.check && node.lang !== 'swift') file.fail('Only ```swift blocks can be marked `check`', node);
            if (meta.run && meta.check) file.fail('A block is either `run` (a whole program) or `check` (a fragment), not both', node);
            if (meta.ios && !meta.check) file.fail('`ios` goes with `check`: write ```swift check ios', node);
            const codeBlock = element('CodeBlock', {
                lang: node.lang ?? 'text',
                code: node.value,
                title: meta.title,
                run: meta.run ? exampleFile(location.module, location.lesson, runnable.length + 1) : undefined,
                pkg: meta.run ? location.packageDir : undefined,
                verify: meta.run ? 'run' : meta.check ? (meta.ios ? 'ios' : 'macos') : undefined,
                highlight: parseLines(meta.highlight),
            });
            if (meta.run) runnable.push({ codeBlock, node });
            replace(codeBlock);
            return undefined;
        });

        // A runnable example promises its output, so the ```output block has to follow it directly
        runnable.forEach(({ codeBlock, node }) => {
            if (codeBlock.data.payload.output === undefined) file.fail('A `run` block needs an ```output block straight after it', node);
        });

        // A design exercise has a workspace, a rubric, and one model answer for each workspace section;
        // an architecture review has a workspace, its findings and a reference review
        if (isDesign || isCritique) {
            if (!workspace) file.fail('A design exercise or review needs a ```workspace block');
            if (isDesign && !rubric) file.fail('A design exercise needs a ```rubric block');
            if (isCritique && !findings) file.fail('An architecture review needs a ```findings block');
            const answered = [];
            let reference = false;
            visit(tree, 'mdxJsxFlowElement', (node) => {
                if (node.name === 'ModelAnswer') answered.push(attributeOf(node, 'section'));
                if (node.name === 'ReferenceReview') reference = true;
            });
            if (isCritique && !reference) file.fail('An architecture review needs a <ReferenceReview>');
            if (isDesign) {
                const ids = workspace.sections.map((item) => item.id);
                const missing = ids.filter((id) => !answered.includes(id));
                const unknown = answered.filter((id) => !ids.includes(id));
                const twice = answered.filter((id, at) => answered.indexOf(id) !== at);
                if (missing.length) file.fail(`Missing <ModelAnswer section="…"> for: ${missing.join(', ')}`);
                if (unknown.length) file.fail(`<ModelAnswer> for sections the workspace doesn't have: ${unknown.join(', ')}`);
                if (twice.length) file.fail(`More than one <ModelAnswer> for: ${twice.join(', ')}`);
            }
        }

        tree.children.push(exportNode({ questions, cards, headings, ...(workspace ? { workspace } : {}), ...(rubric ? { rubric } : {}), ...(findings ? { findings } : {}) }));
    };
}
