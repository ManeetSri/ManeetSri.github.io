// Design exercises and architecture reviews for D13 · Behavioural patterns II
export default [
    {
        id: 'sd-review-behavioural-2-draft-history',
        kind: 'critique',
        title: 'Review a draft editor’s undo history',
        difficulty: 'medium',
        patterns: ['patterns', 'state', 'persistence'],
        lessons: ['sd-behavioural-memento'],
        minutes: 25,
        summary: 'A compose screen whose undo snapshots, autosave and restoration each break a memento rule: find why undo does nothing and why the app crashes at launch.',
    },
];
