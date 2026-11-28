// The design course as the console's pages see it
import { makeLinks } from '../../course/links.js';
import { designData } from './courseData.js';
import { MOCK_CRITERIA } from './skills.js';

export const designCourse = {
    ...designData,
    title: 'System Design',
    shortTitle: 'System design',
    brand: { lead: 'System', joiner: '', accent: 'Design' },
    links: makeLinks(designData.base),
    profileSlot: 'design',
    // Each sheet is src/dsa/design/content/sheets/<id>.mdx
    sheets: [
        { id: 'framework', title: 'Design framework', detail: 'The steps of a mobile system design, and what to cover in each.', keywords: 'interview steps requirements estimate deep dive' },
        { id: 'architectures', title: 'Architectures compared', detail: 'MVC, MVVM, TCA, VIPER, Clean: what each solves and costs.', keywords: 'mvvm tca viper clean redux' },
        { id: 'numbers', title: 'Numbers to know', detail: 'Latency, throughput and estimation numbers for mobile and backend.', keywords: 'latency estimation qps storage bandwidth' },
        { id: 'http', title: 'HTTP & caching', detail: 'Methods, status codes and caching headers.', keywords: 'status codes cache-control etag' },
        { id: 'persistence', title: 'Persistence chooser', detail: 'Which store for which data, from UserDefaults to SQLite.', keywords: 'core data swiftdata keychain sqlite' },
        { id: 'concurrency', title: 'Concurrency', detail: 'GCD, async/await and actors side by side.', keywords: 'gcd async await actor sendable' },
        { id: 'security', title: 'Security checklist', detail: 'MASVS-style checks for an iOS app.', keywords: 'masvs keychain pinning ats' },
        { id: 'performance', title: 'Performance', detail: 'Budgets, and which Instruments tool answers which question.', keywords: 'launch memory energy instruments' },
        { id: 'templates', title: 'Swift templates', detail: 'Type-checked skeletons: API client, repository, coordinator, store and more.', keywords: 'api client repository coordinator di container reducer' },
        { id: 'glossary', title: 'Glossary', detail: 'Every term in the course, in plain words.', keywords: 'terms definitions' },
    ],
    content: {
        lesson: () => import('../content/lessonFiles.js'),
        problem: () => import('../content/kataFiles.js'),
        design: () => import('../content/designFiles.js'),
        critique: () => import('../content/critiqueFiles.js'),
        sheet: () => import('../content/sheetFiles.js'),
    },
    starters: () => import('../content/starterFiles.js'),
    swift: { package: 'design', dir: 'design-swift' },
    // Recalling a whole design takes longer than a fact
    cardMinutes: { design: 5, critique: 4 },
    placementName: 'placement check',
    patternLabel: 'Topic',
    onboarding: {
        skipPoint: 'The quick check lets you skip foundations you already know from shipping apps. Starting from the beginning is completely fine.',
        // Questions with code take longer to read than DSA's
        placementMinutes: 10,
        placementIntro: 'Parts I to IV cover design foundations, patterns and iOS architecture. If you already work with them, a quick check can skip those modules.',
        zeroDetail: 'Begin with what makes software good. Nothing is assumed beyond some Swift.',
        setupPrompt: 'Pick your goal and pace, and optionally skip foundations you already know. It takes two minutes.',
    },
    // Mock interviews draw from design exercises marked for mocks, scored on the design rubric
    mock: {
        kind: 'design',
        durations: [45, 60],
        criteria: MOCK_CRITERIA,
        eligible: (item) => item.kind === 'design' && item.mock,
        intro: 'A random design exercise from topics you’ve finished, a timer, and no model answer. Afterwards you score yourself against the rubric interviewers use.',
        empty: 'Finish a few lessons that have design exercises first: mocks only use topics you’ve learned.',
        noun: 'design',
    },
    practiceIntro: 'Design exercises with model answers and rubrics, Swift katas with tests in the companion package, and architecture reviews.',
};
