// Design exercises and architecture reviews for D24 · Errors, logging & diagnostics
export default [
    {
        id: 'sd-design-diagnostics-pipeline',
        kind: 'design',
        title: 'A diagnostics pipeline for 2 million daily users',
        difficulty: 'hard',
        patterns: ['observability', 'privacy', 'performance'],
        lessons: ['sd-diag-structured-logging', 'sd-diag-crash-reporting', 'sd-diag-signposts', 'sd-diag-logger', 'sd-diag-production-debugging'],
        minutes: 35,
        template: 'component',
        mock: true,
        lists: [],
        summary: 'Design the logs, structured events, signposts, crash reports and breadcrumbs of a food delivery app with 2M daily users, within a privacy rule and a 50 KB a day upload budget.',
    },
    {
        id: 'sd-review-diagnostics-account-screen',
        kind: 'critique',
        title: 'Review: the account screen that hides its failures',
        difficulty: 'medium',
        patterns: ['ui', 'observability', 'security'],
        lessons: ['sd-diag-error-taxonomy', 'sd-diag-programmer-errors', 'sd-diag-error-ux', 'sd-diag-logger', 'sd-diag-propagation'],
        minutes: 25,
        lists: [],
        summary: 'An account screen that crashes on unexpected responses, says Saved when saving failed, logs a bearer token and shows one alert for everything, cancellation included.',
    },
];
