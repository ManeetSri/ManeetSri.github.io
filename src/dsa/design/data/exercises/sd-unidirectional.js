// Design exercises and architecture reviews for D28 · Unidirectional architectures
export default [
    {
        id: 'sd-design-unidirectional-onboarding',
        kind: 'design',
        title: 'A unidirectional onboarding with async validation',
        difficulty: 'hard',
        patterns: ['architecture', 'state', 'navigation', 'testing'],
        lessons: ['sd-udf-tca-scoping', 'sd-udf-tca-navigation', 'sd-udf-tca-effects', 'sd-udf-trade-offs'],
        minutes: 40,
        template: 'feature',
        mock: true,
        lists: [],
        summary: 'Design a five-step sign-up as composed features: debounced username checks that can’t go stale, an email code with a resend timer, a remotely reordered flow, and resume after the app is killed.',
    },
    {
        id: 'sd-review-unidirectional-app-reducer',
        kind: 'critique',
        title: 'Review: one reducer for the whole app',
        difficulty: 'medium',
        patterns: ['architecture', 'state', 'testing'],
        lessons: ['sd-udf-flux-redux', 'sd-udf-tca-reducers', 'sd-udf-tca-effects', 'sd-udf-trade-offs'],
        minutes: 25,
        lists: [],
        summary: 'A Redux-style app store whose reducer starts its own network tasks, reaches for singletons, the clock and UUIDs, and holds every feature’s state, down to the scroll offset.',
    },
];
