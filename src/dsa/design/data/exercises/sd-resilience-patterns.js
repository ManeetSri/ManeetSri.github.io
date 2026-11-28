// Design exercises and architecture reviews for D14 · Concurrency & resilience patterns
export default [
    {
        id: 'sd-review-resilience-patterns-backup-storm',
        kind: 'critique',
        title: 'Review: the 2 a.m. photo backup storm',
        difficulty: 'medium',
        patterns: ['networking', 'concurrency', 'background'],
        lessons: ['sd-resilience-retry-backoff', 'sd-resilience-producer-consumer', 'sd-resilience-rate-limiting'],
        minutes: 25,
        lists: [],
        summary: 'A photo backup service that starts every upload at once, retries without backoff and duplicates photos: find why it takes the API down every night.',
    },
];
