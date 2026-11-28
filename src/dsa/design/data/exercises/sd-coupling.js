// Design exercises and architecture reviews for D03 · Coupling & cohesion
export default [
    {
        id: 'sd-review-coupling-checkout-screen',
        kind: 'critique',
        title: 'Review: the checkout screen',
        difficulty: 'medium',
        patterns: ['principles', 'architecture'],
        lessons: ['sd-coupling-basics', 'sd-coupling-kinds', 'sd-coupling-temporal'],
        minutes: 25,
        summary: 'A checkout screen that finds its dependencies instead of being given them: a global session, a reach into another screen, flags and two vendor SDKs.',
    },
    {
        id: 'sd-review-coupling-app-manager',
        kind: 'critique',
        title: 'Review: the AppManager',
        difficulty: 'medium',
        patterns: ['principles', 'architecture'],
        lessons: ['sd-coupling-cohesion', 'sd-coupling-separation', 'sd-coupling-connascence'],
        minutes: 25,
        summary: 'A singleton every feature calls, holding a session, an image cache, formatting, haptics and analytics. Find the kinds of cohesion, and plan the split.',
    },
];
