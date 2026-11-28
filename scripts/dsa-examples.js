// npm run dsa:examples / design:examples [-- --course <id>] [--verify] [--module <id>…] [--lesson <id>…]
//
// Every lesson ```swift block marked `run` is a complete program. This copies each one to the course's
// package, <package>/Examples/<module>/<lesson>-<n>.swift, so the learner can run it with `swift <file>`.
//
// With --verify it also runs every example, and every quiz "output" question's code, and checks that
// what Swift actually prints matches what the lesson says. Blocks marked `check` (fragments: templates,
// UI code) are type-checked instead, on macOS, or against the iOS simulator SDK when marked `check ios`.
// Blocks with the same `group=<name>` in one file are checked together, in order. Needs the Swift
// toolchain, and Xcode for `ios`.
//   --check      only report generated files that are missing or out of date (used by the content check)
//   --repeat <n> run each example n times: output that varies between runs (a concurrency bug) fails
//   --skip-ios   leave out `check ios` blocks (on a machine without Xcode)
import { execFile } from 'node:child_process';
import { existsSync, mkdirSync, readdirSync, readFileSync, rmSync, writeFileSync, mkdtempSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join, relative } from 'node:path';
import { fileURLToPath } from 'node:url';
import { parse } from 'yaml';
import { COURSES, IOS_TARGET } from './courses.js';
import { fencedBlocks, parseMeta, runnableExamples } from './dsa-content-lib.js';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const RUN_TIMEOUT_MS = 30_000;
const CONCURRENCY = 6;

const args = process.argv.slice(2);
const valuesOf = (flag) => args.flatMap((arg, index) => (arg === flag && args[index + 1] ? [args[index + 1]] : []));
const verify = args.includes('--verify');
const checkOnly = args.includes('--check');
const skipIos = args.includes('--skip-ios');
const repeat = Math.max(1, Number(valuesOf('--repeat')[0] ?? 1));
const onlyModules = valuesOf('--module');
const onlyLessons = valuesOf('--lesson');
const course = COURSES[valuesOf('--course')[0] ?? 'dsa'];
if (!course) throw new Error(`Unknown course (use ${Object.keys(COURSES).join(' or ')})`);

const lessonsDir = join(root, course.lessonsDir);
const sheetsDir = join(root, course.sheetsDir);
const packageDir = join(root, course.packageDir);
const script = course.id === 'dsa' ? 'dsa:examples' : `${course.id}:examples`;

const header = (module, lesson) => `// Generated from ${course.lessonsDir}/${module}/${lesson}.mdx. Edit the lesson, then run\n// \`npm run ${script}\` to update this file. Run it from ${course.packageDir}/ with: swift <this file>\n\n`;

// Matches how --verify compares output: trailing spaces and blank lines at the ends don't count
const normalise = (text) => text.replace(/\r/g, '').split('\n').map((line) => line.trimEnd()).join('\n').trim();

const lessonFiles = existsSync(lessonsDir)
    ? readdirSync(lessonsDir).flatMap((module) => readdirSync(join(lessonsDir, module))
        .filter((name) => name.endsWith('.mdx'))
        .map((name) => ({ module, lesson: name.slice(0, -4), path: join(lessonsDir, module, name) })))
    : [];

const selected = lessonFiles.filter(({ module, lesson }) => (!onlyModules.length || onlyModules.includes(module))
    && (!onlyLessons.length || onlyLessons.includes(lesson)));

const problems = [];
const runs = [];
const checks = [];

// Type-checked fragments in a file: one check per block, or per group of blocks with the same `group`
const collectChecks = (path) => {
    const groups = new Map();
    fencedBlocks(readFileSync(path, 'utf8')).forEach((block) => {
        const meta = parseMeta(block.meta);
        if (block.lang !== 'swift' || !meta.check) return;
        const key = meta.group ? `group:${meta.group}` : `line:${block.line}`;
        const entry = groups.get(key) ?? { label: `${relative(root, path)}:${block.line}`, code: [], ios: false };
        entry.code.push(block.body);
        entry.ios ||= Boolean(meta.ios);
        groups.set(key, entry);
    });
    groups.forEach((entry) => checks.push({ ...entry, code: entry.code.join('\n\n') }));
};

for (const { module, lesson, path } of selected) {
    const source = readFileSync(path, 'utf8');
    const where = relative(root, path);

    for (const example of runnableExamples(source, module, lesson)) {
        const target = join(packageDir, example.file);
        const contents = header(module, lesson) + example.code.replace(/\n*$/, '\n');
        if (checkOnly) {
            if (!existsSync(target) || readFileSync(target, 'utf8') !== contents) problems.push(`${example.file} is missing or out of date (from ${where}:${example.line}). Run npm run ${script}.`);
        } else {
            mkdirSync(dirname(target), { recursive: true });
            writeFileSync(target, contents);
        }
        if (example.output === null) problems.push(`${where}:${example.line}: a run block needs an \`\`\`output block straight after it`);
        else runs.push({ label: `${where}:${example.line} (${example.file})`, code: example.code, expected: example.output, file: target });
    }

    // Quiz "output" questions are checked too, unless they say `verify: false` (code that needs context)
    for (const block of fencedBlocks(source).filter((item) => item.lang === 'quiz')) {
        let questions = [];
        try {
            questions = parse(block.body) ?? [];
        } catch {
            continue; // The build reports YAML errors with their line
        }
        questions.filter((question) => question.type === 'output' && question.verify !== false && question.code).forEach((question) => {
            runs.push({ label: `${where}:${block.line} quiz question "${question.id}"`, code: question.code, expected: question.answer });
        });
    }
}

// Fragments are type-checked rather than run: in lessons, and (for a full run) cheat sheets and practice
selected.forEach(({ path }) => collectChecks(path));
if (!onlyModules.length && !onlyLessons.length) {
    [sheetsDir, ...Object.values(course.practiceDirs).map((dir) => join(root, dir))].filter((dir) => existsSync(dir)).forEach((dir) => {
        readdirSync(dir).filter((name) => name.endsWith('.mdx')).forEach((name) => collectChecks(join(dir, name)));
    });
}

// Generated files for lessons that no longer have them are removed
if (!checkOnly) {
    const examplesDir = join(packageDir, 'Examples');
    const expected = new Set(runs.filter((run) => run.file).map((run) => run.file));
    const modules = onlyModules.length ? onlyModules : (existsSync(examplesDir) ? readdirSync(examplesDir) : []);
    modules.forEach((module) => {
        const dir = join(examplesDir, module);
        if (!existsSync(dir)) return;
        readdirSync(dir).forEach((name) => {
            const lesson = name.replace(/-\d+\.swift$/, '');
            const inScope = !onlyLessons.length || onlyLessons.includes(lesson);
            if (inScope && name.endsWith('.swift') && !expected.has(join(dir, name))) rmSync(join(dir, name));
        });
    });
}

const runSwift = (file) => new Promise((resolve) => {
    execFile('swift', ['-swift-version', course.swiftVersion, file], { cwd: packageDir, timeout: RUN_TIMEOUT_MS, maxBuffer: 1 << 20 }, (error, stdout, stderr) => {
        resolve({ ok: !error, stdout, stderr: stderr || error?.message || '' });
    });
});

// macOS fragments use the host SDK; iOS ones the simulator SDK, so UIKit and friends resolve
const typecheck = (file, ios) => new Promise((resolve) => {
    const [command, commandArgs] = ios
        ? ['xcrun', ['--sdk', 'iphonesimulator', 'swiftc', '-typecheck', '-target', IOS_TARGET, '-swift-version', course.swiftVersion, file]]
        : ['swiftc', ['-typecheck', '-swift-version', course.swiftVersion, file]];
    execFile(command, commandArgs, { timeout: RUN_TIMEOUT_MS * 2 }, (error, stdout, stderr) => {
        resolve({ ok: !error, stderr: stderr || error?.message || '' });
    });
});

const verifyAll = async () => {
    const scratch = mkdtempSync(join(tmpdir(), 'dsa-examples-'));
    let next = 0;
    const worker = async () => {
        while (next < runs.length) {
            const run = runs[next];
            const index = next;
            next += 1;
            let file = run.file;
            if (!file) {
                file = join(scratch, `quiz-${index}.swift`);
                writeFileSync(file, run.code);
            }
            for (let attempt = 1; attempt <= repeat; attempt += 1) {
                const result = await runSwift(file);
                if (!result.ok) {
                    problems.push(`${run.label} didn't run:\n${result.stderr.split('\n').slice(0, 8).join('\n')}`);
                    break;
                } else if (normalise(result.stdout) !== normalise(run.expected)) {
                    problems.push(`${run.label} prints something different${attempt > 1 ? ` on run ${attempt}` : ''}.\n--- the lesson says\n${normalise(run.expected)}\n--- Swift printed\n${normalise(result.stdout)}`);
                    break;
                }
            }
        }
    };
    await Promise.all(Array.from({ length: CONCURRENCY }, worker));
    for (const [index, check] of checks.entries()) {
        if (check.ios && skipIos) continue;
        const file = join(scratch, `check-${index}.swift`);
        writeFileSync(file, check.code);
        const result = await typecheck(file, check.ios);
        if (!result.ok) problems.push(`${check.label} doesn't compile${check.ios ? ' for iOS' : ''}:\n${result.stderr.split('\n').slice(0, 8).join('\n')}`);
    }
    rmSync(scratch, { recursive: true, force: true });
};

if (verify) await verifyAll();

const scope = onlyModules.length || onlyLessons.length ? ` in ${[...onlyModules, ...onlyLessons].join(', ')}` : '';
if (problems.length) {
    console.error(`✘ ${problems.length} problem${problems.length === 1 ? '' : 's'} with examples${scope}:\n`);
    problems.forEach((message) => console.error(`• ${message}\n`));
    process.exit(1);
}
const exampleCount = runs.filter((run) => run.file).length;
const quizCount = runs.length - exampleCount;
const iosCount = checks.filter((check) => check.ios && !skipIos).length;
const checkedCount = checks.filter((check) => !check.ios || !skipIos).length;
console.log(`✔ ${course.title}: ${exampleCount} examples${verify ? ` and ${quizCount} quiz outputs verified${checkedCount ? `, ${checkedCount} fragments type-checked${iosCount ? ` (${iosCount} for iOS)` : ''}` : ''}` : checkOnly ? ' up to date' : ' written'}${scope}.`);
