// npm run dsa:check / design:check / content:check [-- --course <id>] [--module <id>…]
// Keeps each course's manifest, content files, Swift package and generated examples in step, and keeps
// the courses apart (each course's ids carry its prefix, and no id is used by two courses). Quiz and card
// syntax is checked by the build (scripts/remark-dsa-blocks.js, or quickly with npm run dsa:compile);
// this checks how the pieces connect.
import { execFileSync } from 'node:child_process';
import { existsSync, readdirSync, readFileSync, statSync } from 'node:fs';
import { basename, dirname, join, relative } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { COURSES, coursesFromArgs } from './courses.js';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
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
const at = (path) => join(root, path);

// Every course's data, for cross-course rules and for links from one course into another
const data = Object.fromEntries(await Promise.all(Object.values(COURSES).map(async (course) => {
    const module = await import(pathToFileURL(at(course.data)));
    return [course.id, module[course.exportName]];
})));

// Stubs are what the tests run against before you've written anything: they must fail fast, never hang or crash
const FORBIDDEN_IN_STUBS = [
    [/\bfatalError\s*\(/, 'fatalError'],
    [/\bpreconditionFailure\s*\(/, 'preconditionFailure'],
    [/\bwhile\s+true\b/, 'while true'],
    [/\bTask\.sleep\b/, 'Task.sleep'],
    [/\bThread\.sleep\b/, 'Thread.sleep'],
];

const checkCourse = async (course) => {
    const { modules, lessons, practice, DIFFICULTIES, PATTERNS, LISTS } = data[course.id];
    const name = course.title;
    const moduleOfLesson = Object.fromEntries(lessons.map((lesson) => [lesson.id, lesson.module]));

    // Manifest: unique ids, and every reference points at something real
    duplicates(modules.map((module) => module.id)).forEach((id) => fail(`${name}: module id "${id}" is used twice`));
    duplicates(lessons.map((lesson) => lesson.id)).forEach((id) => fail(`${name}: lesson id "${id}" is used twice`));
    duplicates(practice.map((item) => item.id)).forEach((id) => fail(`${name}: practice id "${id}" is used twice`));

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

    // A course's ids carry its prefix, so stored progress can tell the courses apart
    if (course.idPrefix) {
        [...modules, ...lessons, ...practice].filter((item) => !item.id.startsWith(course.idPrefix))
            .forEach((item) => fail(`${name}: id "${item.id}" must start with "${course.idPrefix}"`));
    }

    // Content files: a file's name is its id, and it sits in its module's folder
    const lessonFileIds = new Set();
    filesIn(at(course.lessonsDir), '.mdx').forEach((path) => {
        const id = basename(path, '.mdx');
        const lesson = lessons.find((item) => item.id === id);
        lessonFileIds.add(id);
        if (!inScope(basename(dirname(path))) && !(lesson && inScope(lesson.module))) return;
        if (!lesson) fail(`${relative(root, path)} has no lesson "${id}" in the curriculum`);
        else if (basename(dirname(path)) !== lesson.module) fail(`${relative(root, path)} should be in lessons/${lesson.module}/`);
        else if (lesson.status !== 'ready') fail(`${relative(root, path)} exists, but lesson "${id}" is still marked as a stub`);
    });
    lessons.filter((lesson) => inScope(lesson.module) && lesson.status === 'ready' && !lessonFileIds.has(lesson.id))
        .forEach((lesson) => fail(`Lesson "${lesson.id}" is marked ready but lessons/${lesson.module}/${lesson.id}.mdx is missing`));

    // Each module's practice lives in <registry>/<module>.js and practises that module's lessons
    for (const dir of course.registryDirs) {
        for (const path of filesIn(at(dir), '.js')) {
            const moduleId = basename(path, '.js');
            if (!inScope(moduleId)) continue;
            if (!modules.some((module) => module.id === moduleId)) fail(`${relative(root, path)} isn't named after a module`);
            const { default: list } = await import(pathToFileURL(path));
            list.forEach((item) => item.lessons?.forEach((id) => {
                if (lessonIds.has(id) && moduleOfLesson[id] !== moduleId) fail(`"${item.id}" in ${relative(root, path)} practises "${id}", which belongs to module ${moduleOfLesson[id]}`);
            }));
        }
    }

    // Every practice item has its statement in the folder for its kind, and every statement has an item
    const kindOf = (item) => item.kind ?? 'problem';
    const itemById = Object.fromEntries(practice.map((item) => [item.id, item]));
    const statementIds = Object.fromEntries(Object.entries(course.practiceDirs)
        .map(([kind, dir]) => [kind, new Set(filesIn(at(dir), '.mdx').map((path) => basename(path, '.mdx')))]));
    if (!onlyModules.length) {
        Object.entries(statementIds).forEach(([kind, ids]) => ids.forEach((id) => {
            if (!itemById[id]) fail(`${course.practiceDirs[kind]}/${id}.mdx has no entry in the practice registry`);
            else if (kindOf(itemById[id]) !== kind) fail(`${course.practiceDirs[kind]}/${id}.mdx is in the folder for ${kind} items, but "${id}" is a ${kindOf(itemById[id])}`);
        }));
    }

    const swiftDir = at(course.packageDir);
    const swiftSources = (folder) => filesIn(join(swiftDir, folder), '.swift').map((path) => readFileSync(path, 'utf8')).join('\n');
    const hasKatas = practice.some((item) => kindOf(item) === 'problem');
    const tests = hasKatas ? swiftSources('Tests') : '';
    const exercises = hasKatas ? swiftSources('Sources/Exercises') : '';
    const solutions = hasKatas ? swiftSources('Sources/Solutions') : '';

    practice.filter((item) => item.lessons?.some((id) => inScope(moduleOfLesson[id])) || !onlyModules.length).forEach((item) => {
        const label = `${name} practice "${item.id}"`;
        const kind = kindOf(item);
        if (!course.practiceDirs[kind]) fail(`${label} has unknown kind "${kind}"`);
        else if (!statementIds[kind].has(item.id)) fail(`${label} has no ${course.practiceDirs[kind]}/${item.id}.mdx`);
        if (!item.title) fail(`${label} has no title`);
        if (!DIFFICULTIES[item.difficulty]) fail(`${label} has unknown difficulty "${item.difficulty}"`);
        if (!Array.isArray(item.patterns) || !item.patterns.length) fail(`${label} needs at least one pattern or topic`);
        item.patterns?.forEach((key) => !PATTERNS[key] && fail(`${label} has unknown pattern or topic "${key}"`));
        (item.lists ?? []).forEach((key) => !LISTS[key] && fail(`${label} is in unknown list "${key}"`));
        if (!Number.isFinite(item.minutes)) fail(`${label} needs an estimate in minutes`);
        if (!item.lessons?.length) fail(`${label} isn't linked to any lesson`);
        item.lessons?.forEach((id) => !lessonIds.has(id) && fail(`${label} lists unknown lesson "${id}"`));
        if (kind !== 'problem') return;
        if (!item.swiftTest) {
            fail(`${label} has no swiftTest`);
            return;
        }
        if (!new RegExp(`struct\\s+${item.swiftTest}\\b`).test(tests)) fail(`${label} expects a Swift test suite "${item.swiftTest}" in ${course.packageDir}/Tests`);
        const type = item.swiftTest.replace(/Tests$/, '');
        if (!new RegExp(`enum\\s+${type}\\b`).test(exercises)) fail(`${label} expects "public enum ${type}" in ${course.packageDir}/Sources/Exercises`);
        if (!new RegExp(`enum\\s+${type}\\b`).test(solutions)) fail(`${label} expects "public enum ${type}" in ${course.packageDir}/Sources/Solutions`);
    });

    // Exercise stubs fail their tests quickly; they never hang or crash the whole run
    if (course.id !== 'dsa') {
        filesIn(join(swiftDir, 'Sources/Exercises'), '.swift').forEach((path) => {
            const source = readFileSync(path, 'utf8');
            FORBIDDEN_IN_STUBS.forEach(([pattern, label]) => {
                if (pattern.test(source)) fail(`${relative(root, path)} uses ${label}: a stub must return a placeholder or throw, never crash or wait`);
            });
        });
    }

    // The curated lists are fixed sizes, so adding an item to one means swapping another out
    if (!onlyModules.length) {
        Object.entries(course.fixedLists).forEach(([key, size]) => {
            const count = practice.filter((item) => (item.lists ?? []).includes(key)).length;
            if (count !== size) fail(`${LISTS[key]} has ${count} problems; it must have exactly ${size}`);
        });
    }

    // Links between pages, in either course, must point at something that exists
    filesIn(at(course.contentDir), '.mdx').forEach((path) => {
        const where = relative(root, path);
        // A practice statement belongs to the module of the lessons it practises
        const fileId = basename(path, '.mdx');
        const lessonModule = moduleOfLesson[fileId] ?? moduleOfLesson[practice.find((item) => item.id === fileId)?.lessons?.[0]];
        if (onlyModules.length && !(lessonModule && inScope(lessonModule))) return;
        const text = readFileSync(path, 'utf8');
        for (const [, base, kind, id] of text.matchAll(/\]\(\/(dsa|design)\/(learn|practice|checkpoint)\/([a-z0-9-]+)/g)) {
            const target = data[Object.values(COURSES).find((other) => other.base === `/${base}`).id];
            const known = kind === 'learn' ? Boolean(target.lessonById[id]) : kind === 'practice' ? Boolean(target.practiceById[id]) : Boolean(target.moduleById[id]);
            if (!known) fail(`${where} links to /${base}/${kind}/${id}, which doesn't exist`);
        }
        // MDX reads { … } in prose as a JavaScript expression: {A, B} crashes the page and {0, 1} prints just "1".
        // Content never needs expressions, so any brace outside code must be escaped as \{ and \}.
        let inFence = false;
        text.split('\n').forEach((line, index) => {
            if (line.trimStart().startsWith('```')) {
                inFence = !inFence;
                return;
            }
            if (inFence || /<[A-Za-z]/.test(line)) return;
            const prose = line.replace(/`[^`]*`/g, '');
            if (/(?<!\\)[{}]/.test(prose)) fail(`${where}:${index + 1} has a { or } outside code; write \\{ and \\} so MDX shows it as text`);
        });
    });

    // Generated example files must match the lessons they come from
    try {
        execFileSync('node', [join(root, 'scripts/dsa-examples.js'), '--check', '--course', course.id, ...onlyModules.flatMap((id) => ['--module', id])], { stdio: 'pipe' });
    } catch (error) {
        String(error.stderr).split('\n').filter((line) => line.startsWith('• ')).forEach((line) => fail(line.slice(2)));
    }

    return { lessonFileIds };
};

// Ids are unique across every course, and only the course that owns a prefix uses it
const checkAcrossCourses = () => {
    const owners = new Map();
    Object.values(COURSES).forEach((course) => {
        const { modules, lessons, practice } = data[course.id];
        [...modules, ...lessons, ...practice].forEach((item) => {
            const other = owners.get(item.id);
            if (other && other !== course.id) fail(`Id "${item.id}" is used by both ${COURSES[other].title} and ${course.title}`);
            owners.set(item.id, course.id);
            Object.values(COURSES).filter((owner) => owner.idPrefix && owner.id !== course.id).forEach((owner) => {
                if (item.id.startsWith(owner.idPrefix)) fail(`${course.title} id "${item.id}" starts with "${owner.idPrefix}", which marks ${owner.title} progress`);
            });
        });
    });
};

const selected = coursesFromArgs(args);
const results = [];
for (const course of selected) results.push([course, await checkCourse(course)]);
checkAcrossCourses();

const scope = onlyModules.length ? ` (${onlyModules.join(', ')})` : '';
if (errors.length) {
    console.error(`✘ ${errors.length} problem${errors.length === 1 ? '' : 's'} in ${selected.map((course) => course.title).join(' and ')} content${scope}:\n`);
    errors.forEach((message) => console.error(`  • ${message}`));
    process.exit(1);
}
results.forEach(([course, { lessonFileIds }]) => {
    const { modules, lessons, practice } = data[course.id];
    const ready = lessons.filter((lesson) => lesson.status === 'ready' && lessonFileIds.has(lesson.id)).length;
    console.log(`✔ ${course.title} content is consistent${scope}: ${modules.length} modules, ${lessons.length} lessons (${ready} written), ${practice.length} practice items.`);
});
