// Design exercises and architecture reviews for D05 · More design principles
export default [
    {
        id: 'sd-review-principles-generic-list',
        kind: 'critique',
        title: 'The generic list screen',
        difficulty: 'medium',
        patterns: ['principles', 'ui'],
        lessons: ['sd-principles-dry', 'sd-principles-simplicity', 'sd-principles-cqs', 'sd-principles-grasp-balance'],
        minutes: 25,
        lists: [],
        summary: 'One configurable list controller for every list in the app. Find where sharing became the wrong abstraction, and plan the way back.',
    },
    {
        id: 'sd-design-principles-split-shared-module',
        kind: 'design',
        title: 'Split the Shared module',
        difficulty: 'hard',
        patterns: ['modularity', 'principles'],
        lessons: ['sd-principles-package-cohesion', 'sd-principles-package-coupling'],
        minutes: 35,
        template: 'migration',
        mock: false,
        lists: [],
        summary: 'Break up a grab-bag framework that every target links, using the package cohesion and coupling principles, in steps that keep a weekly release train running.',
    },
];
