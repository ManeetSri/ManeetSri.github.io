// Design exercises and architecture reviews for D12 · Behavioural patterns I
export default [
    {
        id: 'sd-review-behavioural-1-episode-player',
        kind: 'critique',
        title: 'Review: the episode player that never goes away',
        difficulty: 'medium',
        patterns: ['patterns', 'ui'],
        lessons: ['sd-behavioural-delegate', 'sd-behavioural-closure-callbacks', 'sd-behavioural-observer', 'sd-behavioural-target-action'],
        minutes: 25,
        summary: 'A podcast player screen that keeps playing after you close it. Find the cycles, the lost observer tokens and the notifications that crash.',
    },
];
