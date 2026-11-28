// Design exercises and architecture reviews for D01 · Quality attributes & trade-offs
export default [
    {
        id: 'sd-design-quality-transit-ticket',
        kind: 'design',
        title: 'Quality scenarios for a transit ticket',
        difficulty: 'medium',
        patterns: ['architecture', 'offline', 'security', 'accessibility'],
        lessons: ['sd-quality-requirements', 'sd-quality-trust', 'sd-quality-conflicts'],
        minutes: 35,
        template: 'feature',
        mock: false,
        lists: [],
        summary: 'Turn “fast, secure and works in a tunnel” into measurable quality-attribute scenarios for a ticket shown at a metro gate, then let them drive the design.',
    },
    {
        id: 'sd-review-quality-streak-tracker',
        kind: 'critique',
        title: 'A workout streak that nobody can test',
        difficulty: 'easy',
        patterns: ['principles', 'testing', 'state'],
        lessons: ['sd-quality-maintainability', 'sd-quality-complexity', 'sd-quality-tech-debt'],
        minutes: 25,
        lists: [],
        summary: 'A fitness app’s streak logic reads the clock, the disk and three singletons from one method: find what makes it hard to test and change, and plan the fix.',
    },
];
