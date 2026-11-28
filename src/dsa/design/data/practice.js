// The design course's practice: code katas (Swift with tests in design-swift), design exercises (a
// structured answer, then a model answer and rubric) and architecture reviews ("critiques": find the
// problems, then tick the expected findings). Each kind keeps one file per module in its folder.
//
// Kata:     { id, kind: 'problem', title, difficulty, patterns, lessons, swiftTest, lists, minutes }
// Design:   { id, kind: 'design', title, difficulty, patterns, lessons, minutes, template, mock, lists, summary }
// Critique: { id, kind: 'critique', title, difficulty, patterns, lessons, minutes, summary }
// Ids start with `sd-`. `patterns` holds topic keys from TOPICS.
import katas from './katas.js';
import exercises from './exercises.js';

export const DIFFICULTIES = {
    warmup: { label: 'Warm-up', xp: 15 },
    easy: { label: 'Easy', xp: 30 },
    medium: { label: 'Medium', xp: 60 },
    hard: { label: 'Hard', xp: 120 },
    challenge: { label: 'Challenge', xp: 200 },
};

// What a practice item exercises: the filter and chips on the practice pages
export const TOPICS = {
    principles: 'Design principles',
    patterns: 'Design patterns',
    swift: 'Swift design',
    ui: 'UI architecture',
    state: 'State management',
    navigation: 'Navigation',
    di: 'Dependency injection',
    concurrency: 'Concurrency',
    architecture: 'App architecture',
    networking: 'Networking',
    api: 'API design',
    persistence: 'Persistence',
    caching: 'Caching',
    offline: 'Offline & sync',
    realtime: 'Real-time',
    media: 'Media',
    backend: 'Backend',
    scaling: 'Scaling',
    push: 'Push & messaging',
    auth: 'Auth & identity',
    security: 'Security',
    privacy: 'Privacy',
    performance: 'Performance',
    background: 'Background & extensions',
    observability: 'Observability',
    analytics: 'Analytics',
    flags: 'Flags & experiments',
    payments: 'Payments',
    ml: 'On-device ML',
    accessibility: 'Accessibility & localisation',
    testing: 'Testing',
    release: 'Release engineering',
    modularity: 'Modularity',
    leadership: 'Leadership',
};

// Curated lists with fixed sizes (content:check enforces them once each list is complete)
export const LISTS = {
    interview40: 'Interview 40',
    katas50: 'Essential katas 50',
};

export const KIND_LABELS = { problem: 'Kata', design: 'Design', critique: 'Review' };

// Coding katas: the ProblemPage, editor and Swift package serve them like DSA problems
export const problems = katas;
export const problemById = Object.fromEntries(problems.map((problem) => [problem.id, problem]));

// Every practice item, of every kind
export const practice = [...katas, ...exercises];
export const practiceById = Object.fromEntries(practice.map((item) => [item.id, item]));
