// The system design & architecture course, from "what makes software good" to designing whole apps and
// leading architecture. This file is the single source of truth for the course's roadmap, sidebar,
// search, path engine and content checker. Modules live in ./parts/part-NN.js, one file per part.
//
// A lesson is ['id', 'Title', { options }], as in the DSA course. Every id in this course starts with
// `sd-`, which is how the console knows a stored record belongs to this course.
import part00 from './parts/part-00.js';
import part01 from './parts/part-01.js';
import part02 from './parts/part-02.js';
import part03 from './parts/part-03.js';
import part04 from './parts/part-04.js';
import part05 from './parts/part-05.js';
import part06 from './parts/part-06.js';
import part07 from './parts/part-07.js';
import part08 from './parts/part-08.js';
import part09 from './parts/part-09.js';
import part10 from './parts/part-10.js';
import part11 from './parts/part-11.js';
import { practice } from './practice.js';

export const LEVELS = {
    beginner: 'Beginner',
    intermediate: 'Intermediate',
    advanced: 'Advanced',
    expert: 'Expert',
};

export const TRACKS = {
    core: 'Core',
    ios: 'iOS platform',
    interview: 'Interview',
    backend: 'Backend',
    lead: 'Leadership',
    deep: 'Deep dive',
};

// The first goal is the default
export const GOALS = {
    solid: { label: 'Solid app architecture', detail: 'Principles, patterns, the iOS platform and the data layer: what a strong mid-level engineer designs with.', tracks: ['core', 'ios'] },
    interview: { label: 'Senior iOS interviews', detail: 'Solid architecture plus backend basics, case studies and mock design interviews.', tracks: ['core', 'ios', 'interview', 'backend'] },
    staff: { label: 'Staff / architect', detail: 'Interview prep plus scaling codebases and teams, SDK design and architecture leadership.', tracks: ['core', 'ios', 'interview', 'backend', 'lead'] },
    practical: { label: 'Ship better at work', detail: 'Core and iOS topics plus the team-scale practices, without interview drills.', tracks: ['core', 'ios', 'lead'] },
    everything: { label: 'Everything', detail: 'Every lesson, including the deep dives.', tracks: Object.keys(TRACKS) },
};

export const parts = [
    { number: 0, title: 'Start here', phase: 1, summary: 'How the course works, what system design and architecture mean on mobile, and the design framework used throughout.' },
    { number: 1, title: 'Software design foundations', phase: 2, summary: 'Quality attributes, abstraction, coupling and cohesion, SOLID and beyond, Swift as a design language, architecture styles and diagrams.' },
    { number: 2, title: 'Design patterns', phase: 3, summary: 'The classic patterns in Swift, Apple’s own patterns, concurrency and resilience patterns, and refactoring away the anti-patterns.' },
    { number: 3, title: 'iOS platform architecture', phase: 4, summary: 'How an app runs, UIKit and SwiftUI, state, navigation, dependency injection, concurrency, reactive code and diagnostics.' },
    { number: 4, title: 'App architecture patterns', phase: 5, summary: 'MVC, MVVM, unidirectional architectures, VIPER and RIBs, Clean and hexagonal, and choosing and evolving an architecture.' },
    { number: 5, title: 'The data layer', phase: 6, summary: 'Networking, API design, real-time, persistence, caching, offline-first sync and media pipelines.' },
    { number: 6, title: 'Backend for mobile engineers', phase: 7, summary: 'The server side you need to design an app end to end: estimation, scaling, storage, queues, push, auth and reliability.' },
    { number: 7, title: 'Cross-cutting mobile concerns', phase: 8, summary: 'Security, privacy, performance, background work and extensions, accessibility, flags, analytics, payments and on-device ML.' },
    { number: 8, title: 'Testing & delivery', phase: 9, summary: 'Designing for testability, testing in practice, and CI/CD and release engineering.' },
    { number: 9, title: 'Scaling apps & teams', phase: 9, summary: 'Modularisation, design systems, large codebases, cross-platform strategy and SDK design.' },
    { number: 10, title: 'Interviews & case studies', phase: 10, summary: 'The mobile system design interview, dozens of full case studies, and mock interviews.' },
    { number: 11, title: 'Leadership & capstones', phase: 10, summary: 'Leading architecture, and capstone projects that pull the whole course together.' },
];

const rawModules = [part00, part01, part02, part03, part04, part05, part06, part07, part08, part09, part10, part11].flat();

const DEFAULT_MINUTES = 20;

export const modules = rawModules.map((module) => ({
    ...module,
    lessons: module.lessons.map(([id, title, options = {}]) => ({
        id,
        title,
        module: module.id,
        part: module.part,
        level: options.level ?? module.level,
        minutes: options.minutes ?? DEFAULT_MINUTES,
        tracks: options.tracks ?? module.tracks,
        status: options.status ?? module.status ?? 'stub',
        // Every practice item for the lesson, whatever its kind
        problems: practice.filter((item) => item.lessons.includes(id)).map((item) => item.id),
        prereqs: options.prereqs ?? [],
    })),
}));

export const lessons = modules.flatMap((module) => module.lessons);

export const moduleById = Object.fromEntries(modules.map((module) => [module.id, module]));
export const lessonById = Object.fromEntries(lessons.map((lesson) => [lesson.id, lesson]));
export const partByNumber = Object.fromEntries(parts.map((part) => [part.number, part]));
export const modulesInPart = (number) => modules.filter((module) => module.part === number);
