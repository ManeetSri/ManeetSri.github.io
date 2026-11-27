// Shared by the MDX build plugin and the content scripts, so they agree on how blocks are read and
// where runnable examples live.
import { basename, dirname, sep } from 'node:path';

// title="Reverse in place" highlight=2,4-6 run   (a bare word is a flag set to true)
export const parseMeta = (meta) => Object.fromEntries(
    [...(meta ?? '').matchAll(/(\w+)(?:=(?:"([^"]*)"|(\S+)))?/g)].map(([, key, quoted, bare]) => [key, quoted ?? bare ?? true]),
);

// A lesson lives at src/dsa/content/lessons/<module>/<lesson>.mdx
export const lessonLocation = (path) => {
    if (!path || !path.split(sep).join('/').includes('/content/lessons/')) return null;
    return { module: basename(dirname(path)), lesson: basename(path, '.mdx') };
};

// The nth runnable Swift block of a lesson, relative to dsa-swift/. Run it with `swift <path>`.
export const exampleFile = (module, lesson, number) => `Examples/${module}/${lesson}-${number}.swift`;

// Fenced blocks in document order: { lang, meta, body, line }. Lessons never nest fences.
export const fencedBlocks = (source) => {
    const blocks = [];
    const lines = source.split('\n');
    for (let index = 0; index < lines.length; index += 1) {
        const open = lines[index].match(/^(\s*)```(\S*)\s*(.*)$/);
        if (!open) continue;
        const body = [];
        let end = index + 1;
        while (end < lines.length && !/^\s*```\s*$/.test(lines[end])) {
            body.push(lines[end].startsWith(open[1]) ? lines[end].slice(open[1].length) : lines[end]);
            end += 1;
        }
        blocks.push({ lang: open[2] || 'text', meta: open[3], body: body.join('\n'), line: index + 1 });
        index = end;
    }
    return blocks;
};

// Each runnable block and the output the lesson says it prints
export const runnableExamples = (source, module, lesson) => {
    const blocks = fencedBlocks(source);
    const examples = [];
    blocks.forEach((block, index) => {
        if (block.lang !== 'swift' || !parseMeta(block.meta).run) return;
        const next = blocks[index + 1];
        examples.push({
            file: exampleFile(module, lesson, examples.length + 1),
            code: block.body,
            output: next?.lang === 'output' ? next.body : null,
            line: block.line,
        });
    });
    return examples;
};
