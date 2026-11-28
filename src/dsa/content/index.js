// Lessons and problems load one at a time: each MDX file becomes its own small chunk, fetched when opened.
// The maps from ids to those chunks are split by course and kind too, so opening a lesson doesn't also
// download the map of every problem and sheet. Each course lists its loaders in `course.content`.
import { useEffect, useState } from 'react';
import { useCourse } from '../course/context.js';

const EMPTY = '{"questions":[],"cards":[],"headings":[]}';
const loadedMaps = new Map();

// A failed download isn't cached, so it can be retried
const once = (key, load) => {
    if (!loadedMaps.has(key)) {
        loadedMaps.set(key, load().catch((error) => {
            loadedMaps.delete(key);
            throw error;
        }));
    }
    return loadedMaps.get(key);
};

const filesOf = (course, kind) => {
    const load = course.content[kind];
    if (!load) return Promise.resolve({});
    return once(`${course.id}:${kind}`, () => load().then((module) => module.default));
};

// Resolves to null when there's no such file
export const loadContent = async (course, kind, id) => {
    const load = (await filesOf(course, kind))[id];
    if (!load) return null;
    const module = await load();
    return { Content: module.default, data: JSON.parse(module.dsa ?? EMPTY) };
};

// { status: 'loading' | 'ready' | 'missing' | 'error', Content, data }
export const useContent = (kind, id) => {
    const course = useCourse();
    const [result, setResult] = useState({ status: 'loading', key: null });
    const key = `${course.id}:${kind}:${id}`;

    useEffect(() => {
        let cancelled = false;
        loadContent(course, kind, id)
            .then((loaded) => !cancelled && setResult(loaded ? { status: 'ready', key, ...loaded } : { status: 'missing', key }))
            .catch(() => !cancelled && setResult({ status: 'error', key }));
        return () => {
            cancelled = true;
        };
    }, [course, kind, id, key]);

    return result.key === key ? result : { status: 'loading' };
};

// A problem's starter code, the exercise stub its tests run against: { file, code }, or null without one
export const loadStarter = async (course, problem) => {
    if (!course.starters || !problem.swiftTest) return null;
    const map = await once(`${course.id}:starters`, () => course.starters().then((module) => module.default));
    const entry = map[problem.swiftTest.replace(/Tests$/, '')];
    return entry ? { file: entry.file, code: await entry.load() } : null;
};
