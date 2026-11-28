// Architecture reviews for D15 · Anti-patterns & refactoring
export default [
    {
        id: 'sd-review-orders-view-controller',
        kind: 'critique',
        title: 'Review: the orders screen',
        difficulty: 'medium',
        patterns: ['architecture', 'testing'],
        lessons: ['sd-refactoring-massive-vc'],
        minutes: 25,
        summary: 'A view controller that fetches, parses, caches, formats and navigates. Find what makes it fragile.',
    },
];
