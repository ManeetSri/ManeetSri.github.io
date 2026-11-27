// npm run dsa:examples [-- --verify] [--module <id>…] [--lesson <id>…]
//
// Every lesson ```swift block marked `run` is a complete program. This copies each one to
// dsa-swift/Examples/<module>/<lesson>-<n>.swift, so the learner can run it with `swift <file>`.
//
// With --verify it also runs every example, and every quiz "output" question's code, and checks that
// what Swift actually prints matches what the lesson says. Cheat-sheet templates (```swift check) are
// type-checked. Needs the Swift toolchain.
//   --check   only report generated files that are missing or out of date (used by dsa:check)
import { execFile } from 'node:child_process';
import { existsSync, mkdirSync, readdirSync, readFileSync, rmSync, writeFileSync, mkdtempSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join, relative } from 'node:path';
import { fileURLToPath } from 'node:url';
import { parse } from 'yaml';
import { fencedBlocks, parseMeta, runnableExamples } from './dsa-content-lib.js';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const lessonsDir = join(root, 'src/dsa/content/lessons');
const sheetsDir = join(root, 'src/dsa/content/sheets');
const packageDir = join(root, 'dsa-swift');
const RUN_TIMEOUT_MS = 30_000;
const CONCURRENCY = 6;

const args = process.argv.slice(2);
const valuesOf = (flag) => args.flatMap((arg, index) => (arg === flag && args[index + 1] ? [args[index + 1]] : []));
const verify = args.includes('--verify');
const checkOnly = args.includes('--check');
const onlyModules = valuesOf('--module');
const onlyLessons = valuesOf('--lesson');

const header = (module, lesson) => `// Generated from src/dsa/content/lessons/${module}/${lesson}.mdx. Edit the lesson, then run\n// \`npm run dsa:examples\` to update this file. Run it from dsa-swift/ with: swift <this file>\n\n`;

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

for (const { module, lesson, path } of selected) {
    const source = readFileSync(path, 'utf8');
    const where = relative(root, path);

    for (const example of runnableExamples(source, module, lesson)) {
        const target = join(packageDir, example.file);
        const contents = header(module, lesson) + example.code.replace(/\n*$/, '\n');
        if (checkOnly) {
            if (!existsSync(target) || readFileSync(target, 'utf8') !== contents) problems.push(`${example.file} is missing or out of date (from ${where}:${example.line}). Run npm run dsa:examples.`);
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

// Cheat-sheet templates are fragments, so they're type-checked rather than run
const checks = [];
if (!onlyModules.length && !onlyLessons.length && existsSync(sheetsDir)) {
    readdirSync(sheetsDir).filter((name) => name.endsWith('.mdx')).forEach((name) => {
        const path = join(sheetsDir, name);
        fencedBlocks(readFileSync(path, 'utf8'))
            .filter((block) => block.lang === 'swift' && parseMeta(block.meta).check)
            .forEach((block) => checks.push({ label: `${relative(root, path)}:${block.line}`, code: block.body }));
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
    execFile('swift', [file], { cwd: packageDir, timeout: RUN_TIMEOUT_MS, maxBuffer: 1 << 20 }, (error, stdout, stderr) => {
        resolve({ ok: !error, stdout, stderr: stderr || error?.message || '' });
    });
});

const typecheck = (file) => new Promise((resolve) => {
    execFile('swiftc', ['-typecheck', '-swift-version', '5', file], { timeout: RUN_TIMEOUT_MS }, (error, stdout, stderr) => {
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
            const result = await runSwift(file);
            if (!result.ok) {
                problems.push(`${run.label} didn't run:\n${result.stderr.split('\n').slice(0, 8).join('\n')}`);
            } else if (normalise(result.stdout) !== normalise(run.expected)) {
                problems.push(`${run.label} prints something different.\n--- the lesson says\n${normalise(run.expected)}\n--- Swift printed\n${normalise(result.stdout)}`);
            }
        }
    };
    await Promise.all(Array.from({ length: CONCURRENCY }, worker));
    for (const [index, check] of checks.entries()) {
        const file = join(scratch, `sheet-${index}.swift`);
        writeFileSync(file, check.code);
        const result = await typecheck(file);
        if (!result.ok) problems.push(`${check.label} doesn't compile:\n${result.stderr.split('\n').slice(0, 8).join('\n')}`);
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
console.log(`✔ ${exampleCount} examples${verify ? ` and ${quizCount} quiz outputs verified${checks.length ? `, ${checks.length} cheat-sheet templates type-checked` : ''}` : checkOnly ? ' up to date' : ' written'}${scope}.`);
