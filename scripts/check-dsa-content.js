// npm run dsa:check [-- --module <id>…]: keeps the learning console's manifest, content files, Swift
// package and generated examples in step. Quiz and card syntax is checked by the build
// (scripts/remark-dsa-blocks.js, or quickly with npm run dsa:compile); this checks how the pieces connect.
import { execFileSync } from 'node:child_process';
import { existsSync, readdirSync, readFileSync, statSync } from 'node:fs';
import { basename, dirname, join, relative } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { lessons, modules } from '../src/dsa/data/curriculum.js';
import { DIFFICULTIES, LISTS, PATTERNS, problems } from '../src/dsa/data/problems.js';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const lessonsDir = join(root, 'src/dsa/content/lessons');
const problemsDir = join(root, 'src/dsa/content/problems');
const registryDir = join(root, 'src/dsa/data/problems');
const swiftDir = join(root, 'dsa-swift');

const args = process.argv.slice(2);
const onlyModules = args.flatMap((arg, index) => (arg === '--module' && args[index + 1] ? [args[index + 1]] : []));
const inScope = (moduleId) => !onlyModules.length || onlyModules.includes(moduleId);

const errors = [];
const fail = (message) => errors.push(message);

const filesIn = (dir, extension) => {
    if (!existsSync(dir)) return [];
    return readdirSync(dir).flatMap((name) => {
        const path = join(dir, name);
        if (statSync(path).isDirectory()) return filesIn(path, extension);
        return name.endsWith(extension) ? [path] : [];
    });
};

const duplicates = (ids) => ids.filter((id, index) => ids.indexOf(id) !== index);
const moduleOfLesson = Object.fromEntries(lessons.map((lesson) => [lesson.id, lesson.module]));

// Manifest: unique ids, and every reference points at something real
duplicates(modules.map((module) => module.id)).forEach((id) => fail(`Module id "${id}" is used twice`));
duplicates(lessons.map((lesson) => lesson.id)).forEach((id) => fail(`Lesson id "${id}" is used twice`));
duplicates(problems.map((problem) => problem.id)).forEach((id) => fail(`Problem id "${id}" is used twice`));

// Modules may only require modules listed before them, which also rules out cycles
const seenModules = new Set();
modules.forEach((module) => {
    module.requires.forEach((id) => {
        if (!modules.some((other) => other.id === id)) fail(`Module ${module.id} requires unknown module "${id}"`);
        else if (!seenModules.has(id)) fail(`Module ${module.id} requires "${id}", which comes after it`);
    });
    seenModules.add(module.id);
});

const lessonIds = new Set(lessons.map((lesson) => lesson.id));
lessons.filter((lesson) => inScope(lesson.module)).forEach((lesson) => {
    lesson.prereqs.forEach((id) => !lessonIds.has(id) && fail(`Lesson ${lesson.id} has unknown prerequisite "${id}"`));
    if (!['stub', 'ready'].includes(lesson.status)) fail(`Lesson ${lesson.id} has unknown status "${lesson.status}"`);
});

// Content files: a file's name is its id, and it sits in its module's folder
const lessonFileIds = new Set();
filesIn(lessonsDir, '.mdx').forEach((path) => {
    const id = basename(path, '.mdx');
    const lesson = lessons.find((item) => item.id === id);
    lessonFileIds.add(id);
    if (!inScope(basename(dirname(path))) && !(lesson && inScope(lesson.module))) return;
    if (!lesson) fail(`${relative(root, path)} has no lesson "${id}" in curriculum.js`);
    else if (basename(dirname(path)) !== lesson.module) fail(`${relative(root, path)} should be in lessons/${lesson.module}/`);
    else if (lesson.status !== 'ready') fail(`${relative(root, path)} exists, but lesson "${id}" is still marked as a stub`);
});
lessons.filter((lesson) => inScope(lesson.module) && lesson.status === 'ready' && !lessonFileIds.has(lesson.id))
    .forEach((lesson) => fail(`Lesson "${lesson.id}" is marked ready but lessons/${lesson.module}/${lesson.id}.mdx is missing`));

// Each module's problems live in data/problems/<module>.js and practise that module's lessons
for (const path of filesIn(registryDir, '.js')) {
    const moduleId = basename(path, '.js');
    if (!inScope(moduleId)) continue;
    if (!modules.some((module) => module.id === moduleId)) fail(`${relative(root, path)} isn't named after a module`);
    const { default: list } = await import(pathToFileURL(path));
    list.forEach((problem) => problem.lessons?.forEach((id) => {
        if (lessonIds.has(id) && moduleOfLesson[id] !== moduleId) fail(`Problem "${problem.id}" in ${relative(root, path)} practises "${id}", which belongs to module ${moduleOfLesson[id]}`);
    }));
}

const problemFileIds = new Set(filesIn(problemsDir, '.mdx').map((path) => basename(path, '.mdx')));
const problemIds = new Set(problems.map((problem) => problem.id));
if (!onlyModules.length) problemFileIds.forEach((id) => !problemIds.has(id) && fail(`problems/${id}.mdx has no entry in src/dsa/data/problems/`));

// Problems: valid metadata, real lessons, a statement, and Swift exercise, solution and tests
const swiftSources = (folder) => filesIn(join(swiftDir, folder), '.swift').map((path) => readFileSync(path, 'utf8')).join('\n');
const tests = swiftSources('Tests');
const exercises = swiftSources('Sources/Exercises');
const solutions = swiftSources('Sources/Solutions');

problems.filter((problem) => problem.lessons.some((id) => inScope(moduleOfLesson[id])) || !onlyModules.length).forEach((problem) => {
    const name = `Problem "${problem.id}"`;
    if (!problemFileIds.has(problem.id)) fail(`${name} has no src/dsa/content/problems/${problem.id}.mdx`);
    if (!problem.title) fail(`${name} has no title`);
    if (!DIFFICULTIES[problem.difficulty]) fail(`${name} has unknown difficulty "${problem.difficulty}"`);
    if (!Array.isArray(problem.patterns) || !problem.patterns.length) fail(`${name} needs at least one pattern`);
    problem.patterns?.forEach((key) => !PATTERNS[key] && fail(`${name} has unknown pattern "${key}"`));
    (problem.lists ?? []).forEach((key) => !LISTS[key] && fail(`${name} is in unknown list "${key}"`));
    if (!Number.isFinite(problem.minutes)) fail(`${name} needs an estimate in minutes`);
    if (!problem.lessons?.length) fail(`${name} isn't linked to any lesson`);
    problem.lessons?.forEach((id) => !lessonIds.has(id) && fail(`${name} lists unknown lesson "${id}"`));
    if (!problem.swiftTest) {
        fail(`${name} has no swiftTest`);
        return;
    }
    if (!new RegExp(`struct\\s+${problem.swiftTest}\\b`).test(tests)) fail(`${name} expects a Swift test suite "${problem.swiftTest}" in dsa-swift/Tests`);
    const type = problem.swiftTest.replace(/Tests$/, '');
    if (!new RegExp(`enum\\s+${type}\\b`).test(exercises)) fail(`${name} expects "public enum ${type}" in dsa-swift/Sources/Exercises`);
    if (!new RegExp(`enum\\s+${type}\\b`).test(solutions)) fail(`${name} expects "public enum ${type}" in dsa-swift/Sources/Solutions`);
});

// Links between pages must point at lessons and problems that exist
const problemIdSet = new Set(problems.map((problem) => problem.id));
filesIn(join(root, 'src/dsa/content'), '.mdx').forEach((path) => {
    const where = relative(root, path);
    const lessonModule = moduleOfLesson[basename(path, '.mdx')];
    if (onlyModules.length && !(lessonModule && inScope(lessonModule))) return;
    const text = readFileSync(path, 'utf8');
    for (const [, kind, id] of text.matchAll(/\]\(\/dsa\/(learn|practice|checkpoint)\/([a-z0-9-]+)/g)) {
        const known = kind === 'learn' ? lessonIds.has(id) : kind === 'practice' ? problemIdSet.has(id) : modules.some((module) => module.id === id);
        if (!known) fail(`${where} links to /dsa/${kind}/${id}, which doesn't exist`);
    }
});

// Generated example files must match the lessons they come from
try {
    execFileSync('node', [join(root, 'scripts/dsa-examples.js'), '--check', ...onlyModules.flatMap((id) => ['--module', id])], { stdio: 'pipe' });
} catch (error) {
    String(error.stderr).split('\n').filter((line) => line.startsWith('• ')).forEach((line) => fail(line.slice(2)));
}

const scope = onlyModules.length ? ` (${onlyModules.join(', ')})` : '';
if (errors.length) {
    console.error(`✘ ${errors.length} problem${errors.length === 1 ? '' : 's'} in the DSA content${scope}:\n`);
    errors.forEach((message) => console.error(`  • ${message}`));
    process.exit(1);
}
const ready = lessons.filter((lesson) => lesson.status === 'ready' && lessonFileIds.has(lesson.id)).length;
console.log(`✔ DSA content is consistent${scope}: ${modules.length} modules, ${lessons.length} lessons (${ready} written), ${problems.length} problems.`);
