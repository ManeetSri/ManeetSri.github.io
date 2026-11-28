// Part VIII: Testing & delivery (D58–D60). Designing code so it can be tested, testing it at every
// level of the pyramid, and getting it safely through CI, signing, TestFlight and the App Store.
//
// A lesson is ['id', 'Title', { options }]. Options default to the module's level and tracks, and
// 20 minutes. Lesson ids are permanent: progress is stored against them.

export default [
    {
        id: 'sd-testability', code: 'D58', part: 8, title: 'Designing for testability', level: 'intermediate', tracks: ['core'], requires: ['sd-di', 'sd-refactoring'],
        summary: 'Seams, test doubles and injected non-determinism, the shape of a healthy test suite, and where to draw boundaries around networks, storage and system frameworks.',
        lessons: [
            ['sd-testability-what-makes-testable', 'What makes code testable', { minutes: 15 }],
            ['sd-testability-seams', 'Seams: where tests get a grip'],
            ['sd-testability-test-doubles', 'Test doubles: dummy, stub, spy, mock and fake', { minutes: 25 }],
            ['sd-testability-doubles-in-swift', 'Writing doubles in Swift, and when not to mock'],
            ['sd-testability-controlling-time', 'Controlling time: clocks, timers and schedulers', { minutes: 25 }],
            ['sd-testability-randomness-locale', 'Injecting randomness, UUIDs and locale', { minutes: 15 }],
            ['sd-testability-pyramid-trophy', 'The test pyramid vs the testing trophy', { minutes: 15 }],
            ['sd-testability-per-layer', 'What to test in each layer'],
            ['sd-testability-network-persistence', 'Testing boundaries: network and persistence'],
            ['sd-testability-system-frameworks', 'Wrapping system frameworks for tests'],
        ],
    },
    {
        id: 'sd-testing', code: 'D59', part: 8, title: 'Testing in practice', level: 'intermediate', tracks: ['core'], requires: ['sd-testability', 'sd-concurrency', 'sd-mvvm'],
        summary: 'Writing the tests themselves: unit tests for async code, streams, view models and reducers, integration and contract tests, snapshot and UI tests, performance tests, and keeping the suite trustworthy.',
        lessons: [
            ['sd-testing-swift-testing-xctest', 'Swift Testing and XCTest', { minutes: 25 }],
            ['sd-testing-async-actors', 'Testing async code and actors', { minutes: 25 }],
            ['sd-testing-combine-observation', 'Testing Combine pipelines and Observation'],
            ['sd-testing-view-models-reducers', 'Testing view models and reducers', { minutes: 25 }],
            ['sd-testing-network-contracts', 'Network tests: URLProtocol stubs and API contracts', { minutes: 25, level: 'advanced' }],
            ['sd-testing-snapshots', 'Snapshot tests'],
            ['sd-testing-xcuitest', 'XCUITest: page objects and launch arguments', { minutes: 25 }],
            ['sd-testing-performance', 'Performance tests', { minutes: 15, level: 'advanced' }],
            ['sd-testing-flaky-coverage', 'Flaky tests, and coverage vs confidence'],
            ['sd-testing-tdd-feature', 'TDD on a feature, end to end', { minutes: 30 }],
        ],
    },
    {
        id: 'sd-release', code: 'D60', part: 8, title: 'CI/CD & release engineering', level: 'intermediate', tracks: ['ios'], requires: ['sd-testing', 'sd-flags'],
        summary: 'Building, signing and shipping iOS apps through CI, TestFlight and phased releases, and controlling what is live when mobile cannot simply roll back.',
        lessons: [
            ['sd-release-pipelines', 'What a mobile delivery pipeline does', { minutes: 15 }],
            ['sd-release-ci-tools', 'Xcode Cloud, GitHub Actions and fastlane', { minutes: 25 }],
            ['sd-release-signing', 'Signing and provisioning at scale', { minutes: 25, level: 'advanced' }],
            ['sd-release-versioning-testflight', 'Versioning, build numbers and TestFlight'],
            ['sd-release-trains', 'Release trains and release branches', { level: 'advanced', tracks: ['lead'] }],
            ['sd-release-phased', 'Phased releases and monitoring a rollout'],
            ['sd-release-health-gates', 'Release-health gates', { level: 'advanced' }],
            ['sd-release-hotfixes', "Hotfixes and mobile's rollback limits"],
            ['sd-release-app-review', 'Designing within App Review constraints', { minutes: 15 }],
            ['sd-release-forced-updates', 'Forced and soft updates, and minimum supported versions'],
        ],
    },
];
