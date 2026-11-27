// Lessons and problems load one at a time: each MDX file becomes its own small chunk, fetched when opened.
// The maps from ids to those chunks are split by kind too, so opening a lesson doesn't also download the
// map of every problem and sheet.
import { useEffect, useState } from 'react';

const maps = {
    lesson: () => import('./lessonFiles.js'),
    problem: () => import('./problemFiles.js'),
    sheet: () => import('./sheetFiles.js'),
};
const loadedMaps = {};
const filesOf = (kind) => (loadedMaps[kind] ??= maps[kind]().then((module) => module.default));

// Resolves to null when there's no such file
export const loadContent = async (kind, id) => {
    const load = (await filesOf(kind))[id];
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
        loadContent(kind, id)
            .then((loaded) => !cancelled && setResult(loaded ? { status: 'ready', key, ...loaded } : { status: 'missing', key }))
            .catch(() => !cancelled && setResult({ status: 'error', key }));
        return () => {
            cancelled = true;
        };
    }, [kind, id, key]);

    return result.key === key ? result : { status: 'loading' };
};
