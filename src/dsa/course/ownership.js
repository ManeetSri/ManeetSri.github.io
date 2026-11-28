// Every stored record belongs to one course, decided by its id: a course's ids start with its prefix, and
// anything without another course's prefix belongs to the course that has none (DSA). So DSA's records
// never needed migrating, and each course's pages only ever see their own progress.
import { COURSE_DATA } from './registry.js';

const prefixed = Object.values(COURSE_DATA).filter((course) => course.idPrefix);
export const DEFAULT_COURSE = Object.values(COURSE_DATA).find((course) => !course.idPrefix).id;

export const courseOfId = (id = '') => prefixed.find((course) => id.startsWith(course.idPrefix))?.id ?? DEFAULT_COURSE;

// Which course a stored document belongs to, or null for what's shared (the profile and daily minutes)
export const ownerOf = (collection, id, doc) => {
    if (collection === 'meta' || collection === 'activity') return null;
    if (collection === 'mocks') return doc?.course ?? DEFAULT_COURSE;
    // Lesson cards are keyed by lesson id; practice cards (problem~id, design~id) carry the item in `ref`
    if (collection === 'cards') return courseOfId(doc?.lessonId ?? doc?.ref ?? id);
    return courseOfId(id);
};

export const OWNED = ['lessons', 'problems', 'designs', 'cards', 'notes', 'checkpoints', 'mocks'];

// The store replaces a collection's object whenever it changes, so filtering is cached per object
const cache = new WeakMap();
const ownedBy = (collection, docs, courseId) => {
    let byCourse = cache.get(docs);
    if (!byCourse) {
        byCourse = new Map();
        cache.set(docs, byCourse);
    }
    if (!byCourse.has(courseId)) {
        byCourse.set(courseId, Object.fromEntries(Object.entries(docs).filter(([id, doc]) => ownerOf(collection, id, doc) === courseId)));
    }
    return byCourse.get(courseId);
};

// The state with every owned collection narrowed to one course; shared collections pass through
export const filterState = (state, courseId) => ({
    ...state,
    ...Object.fromEntries(OWNED.map((name) => [name, ownedBy(name, state[name] ?? {}, courseId)])),
});
