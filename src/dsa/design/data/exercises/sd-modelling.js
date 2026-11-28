// Design exercises and architecture reviews for D02 · Abstraction & modelling
export default [
    {
        id: 'sd-review-modelling-anaemic-ticket-order',
        kind: 'critique',
        title: 'An anaemic ticket order',
        difficulty: 'easy',
        patterns: ['principles', 'swift'],
        lessons: ['sd-modelling-domain-types', 'sd-modelling-information-hiding'],
        minutes: 25,
        lists: [],
        summary: 'A ticket checkout where statuses are strings, money is a Double and every rule lives in a view model: find why refunds never happen and plan the move to a real domain model.',
    },
    {
        id: 'sd-design-modelling-class-booking',
        kind: 'design',
        title: 'The domain model for booking fitness classes',
        difficulty: 'medium',
        patterns: ['architecture', 'state', 'offline'],
        lessons: ['sd-modelling-aggregates', 'sd-modelling-worked-example'],
        minutes: 40,
        template: 'component',
        mock: false,
        lists: [],
        summary: 'Model classes that fill in a minute, waitlists, credits and late cancellations: the types, the aggregates, who enforces each rule, and how it fails.',
    },
];
