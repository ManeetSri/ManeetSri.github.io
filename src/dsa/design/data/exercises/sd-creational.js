// Design exercises and architecture reviews for D10 · Creational patterns
export default [
    {
        id: 'sd-review-creational-profile-singletons',
        kind: 'critique',
        title: 'Review: singletons and hidden construction',
        difficulty: 'medium',
        patterns: ['patterns', 'di', 'concurrency'],
        lessons: ['sd-creational-singleton-alternatives', 'sd-creational-singleton', 'sd-creational-lazy', 'sd-creational-object-pools'],
        minutes: 30,
        lists: [],
        summary: 'A profile screen built on annotated-into-silence singletons crashes, stutters and shows the last user’s data: find out why.',
    },
];
