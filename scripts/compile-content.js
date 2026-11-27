// npm run dsa:compile [-- --module <id>…] [paths…]
// Compiles lesson and problem MDX exactly as the site build does, without building the site, and
// reports every error with its file and line. Quick to run while writing content.
import { readdirSync, readFileSync } from 'node:fs';
import { dirname, join, relative, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { compile } from '@mdx-js/mdx';
import remarkGfm from 'remark-gfm';
import { VFile } from 'vfile';
import remarkDsaBlocks from './remark-dsa-blocks.js';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const contentDir = join(root, 'src/dsa/content');
const args = process.argv.slice(2);
const modules = args.flatMap((arg, index) => (arg === '--module' && args[index + 1] ? [args[index + 1]] : []));
const paths = args.filter((arg, index) => !arg.startsWith('--') && args[index - 1] !== '--module').map((path) => resolve(path));

const allFiles = (dir) => readdirSync(dir, { withFileTypes: true }).flatMap((entry) => (entry.isDirectory()
    ? allFiles(join(dir, entry.name))
    : entry.name.endsWith('.mdx') ? [join(dir, entry.name)] : []));

let files = paths.length ? paths : allFiles(contentDir);
if (modules.length) files = files.filter((file) => modules.some((module) => file.includes(`/lessons/${module}/`)));

const failures = [];
for (const path of files) {
    try {
        await compile(new VFile({ path, value: readFileSync(path, 'utf8') }), { remarkPlugins: [remarkGfm, remarkDsaBlocks] });
    } catch (error) {
        const line = error.line ?? error.place?.start?.line ?? error.place?.line ?? '?';
        failures.push(`${relative(root, path)}:${line}  ${String(error.reason ?? error.message).split('\n')[0]}`);
    }
}

if (failures.length) {
    console.error(`✘ ${failures.length} of ${files.length} files don't compile:\n`);
    failures.forEach((message) => console.error(`  • ${message}`));
    process.exit(1);
}
console.log(`✔ ${files.length} MDX file${files.length === 1 ? '' : 's'} compile.`);
