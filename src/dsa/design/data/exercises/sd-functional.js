// Design exercises and architecture reviews for D07 · Functional design for apps
export default [
    {
        id: 'sd-review-functional-promo-code',
        kind: 'critique',
        title: 'Review: a promo code tangled in side effects',
        difficulty: 'medium',
        patterns: ['architecture', 'testing', 'principles'],
        lessons: ['sd-functional-pure', 'sd-functional-core-shell', 'sd-functional-composition'],
        summary: 'A checkout view model that mixes pricing rules with the network, UserDefaults, the clock and haptics, and gets prices and errors wrong because of it.',
        lists: [],
        minutes: 25,
    },
];
