// The DSA course as the console's pages see it: its data, plus links, copy and the loaders for its content
import { makeLinks } from '../course/links.js';
import { dsaData } from './courseData.js';

export const dsaCourse = {
    ...dsaData,
    title: 'DSA in Swift',
    shortTitle: 'DSA',
    // Drawn in the top bar as "DSA in Swift", with the last word in the Swift gradient
    brand: { lead: 'DSA', joiner: 'in', accent: 'Swift' },
    links: makeLinks(dsaData.base),
    // Where this course keeps its progress settings in meta/profile: DSA uses the top level
    profileSlot: null,
    // Each sheet is src/dsa/content/sheets/<id>.mdx
    sheets: [
        { id: 'big-o', title: 'Big-O reference', detail: 'Every structure’s operations, every sort, and what n allows.', keywords: 'complexity table sorting costs' },
        { id: 'swift-collections', title: 'Swift collections', detail: 'Array, Set, Dictionary and String, with their costs.', keywords: 'array set dictionary string api' },
        { id: 'templates', title: 'Code templates', detail: 'Swift skeletons for the patterns you’ll use again and again.', keywords: 'binary search bfs dfs dijkstra union find backtracking dp' },
        { id: 'patterns', title: 'Pattern chooser', detail: 'From the wording and constraints of a problem to a technique.', keywords: 'which technique signals' },
        { id: 'glossary', title: 'Glossary', detail: 'Every term in the course, in plain words.', keywords: 'terms definitions' },
    ],
    content: {
        lesson: () => import('../content/lessonFiles.js'),
        problem: () => import('../content/problemFiles.js'),
        sheet: () => import('../content/sheetFiles.js'),
    },
    starters: () => import('../content/starterFiles.js'),
    swift: { package: 'dsa', dir: 'dsa-swift' },
    // Course-specific wording used across pages
    placementName: 'Swift placement check',
    patternLabel: 'Pattern',
    onboarding: {
        skipPoint: 'The quick check lets you skip Swift topics you already know. Starting from zero is completely fine.',
        placementIntro: 'Part I teaches Swift from the very beginning. If you already know some of it, a quick check can skip those modules.',
        zeroDetail: 'Begin with your first Swift program. Nothing is assumed.',
        setupPrompt: 'Pick your goal and pace, and optionally skip Swift you already know. It takes two minutes.',
    },
    practiceIntro: 'Every problem has hints, several approaches, an editor that saves your code, and tests you run in the companion Swift package.',
    // Review minutes per card kind; anything missing counts as one minute
    cardMinutes: {},
};
