// Lessons and problems load one at a time: each MDX file becomes its own small chunk, fetched when opened.
// A file's name is its id, so lessons can move between folders without losing progress.
import { useEffect, useState } from 'react';

const lessonFiles = import.meta.glob('./lessons/**/*.mdx');
const problemFiles = import.meta.glob('./problems/*.mdx');
const sheetFiles = import.meta.glob('./sheets/*.mdx');

const byId = (files) => Object.fromEntries(Object.entries(files).map(([path, load]) => [path.split('/').pop().replace(/\.mdx$/, ''), load]));

const loaders = { lesson: byId(lessonFiles), problem: byId(problemFiles), sheet: byId(sheetFiles) };

export const hasContent = (kind, id) => Boolean(loaders[kind][id]);

export const loadContent = async (kind, id) => {
    const load = loaders[kind][id];
    if (!load) return null;
    const module = await load();
    return { Content: module.default, data: JSON.parse(module.dsa ?? '{"questions":[],"cards":[],"headings":[]}') };
};

// { status: 'loading' | 'ready' | 'missing' | 'error', Content, data }
export const useContent = (kind, id) => {
    const [result, setResult] = useState({ status: 'loading', key: null });
    const key = `${kind}:${id}`;

    useEffect(() => {
        let cancelled = false;
        if (!hasContent(kind, id)) return undefined;
        loadContent(kind, id)
            .then((loaded) => !cancelled && setResult({ status: 'ready', key, ...loaded }))
            .catch(() => !cancelled && setResult({ status: 'error', key }));
        return () => {
            cancelled = true;
        };
    }, [kind, id, key]);

    if (!hasContent(kind, id)) return { status: 'missing' };
    return result.key === key ? result : { status: 'loading' };
};
