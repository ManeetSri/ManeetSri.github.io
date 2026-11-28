// Design exercises and architecture reviews for D19 · State management
export default [
    {
        id: 'sd-design-state-multi-tab-app',
        kind: 'design',
        title: 'App-wide state for a multi-tab app',
        difficulty: 'hard',
        patterns: ['state', 'architecture', 'navigation'],
        lessons: ['sd-state-kinds', 'sd-state-global-stores', 'sd-state-persist-restore', 'sd-state-navigation-coupling'],
        minutes: 35,
        template: 'component',
        mock: true,
        lists: [],
        summary: 'Design the state layer of a four-tab grocery app: who owns the basket, products and navigation, across windows, offline and through sign-out.',
    },
    {
        id: 'sd-review-state-duplicated-truth',
        kind: 'critique',
        title: 'Review: duplicated sources of truth',
        difficulty: 'medium',
        patterns: ['state', 'ui'],
        lessons: ['sd-state-source-of-truth', 'sd-state-derived'],
        minutes: 25,
        lists: [],
        summary: 'A shopping list screen that stores every fact two or three times. Find each copy, and what drifts when.',
    },
];
