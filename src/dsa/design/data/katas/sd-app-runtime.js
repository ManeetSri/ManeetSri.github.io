// Katas for D16 · How an iOS app runs
export default [
    {
        id: 'sd-kata-app-runtime-lifecycle-machine',
        kind: 'problem',
        title: 'App lifecycle machine',
        difficulty: 'medium',
        patterns: ['architecture', 'state', 'background'],
        lessons: ['sd-runtime-app-states', 'sd-runtime-swiftui-app'],
        swiftTest: 'AppRuntimeLifecycleTests',
        lists: [],
        minutes: 30,
    },
    {
        id: 'sd-kata-app-runtime-leak-audit',
        kind: 'problem',
        title: 'Ownership leak audit',
        difficulty: 'medium',
        patterns: ['architecture', 'performance', 'testing'],
        lessons: ['sd-runtime-ownership'],
        swiftTest: 'OwnershipLeakAuditTests',
        lists: [],
        minutes: 35,
    },
];
