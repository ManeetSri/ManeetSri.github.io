// Part IX: Scaling apps & teams (D61–D65). What changes when an app and its team get big:
// modules, a shared design system, large-codebase tooling, cross-platform and multi-app
// strategy, and building SDKs other teams depend on. Hands-on lessons are core or iOS; the
// strategy and organisation lessons are on the lead track.
//
// A lesson is ['id', 'Title', { options }]. Options default to the module's level and tracks, and
// 20 minutes. Lesson ids are permanent: progress is stored against them.

export default [
    {
        id: 'sd-modularisation', code: 'D61', part: 9, title: 'Modularisation', level: 'intermediate', tracks: ['core'], requires: ['sd-arch-evolution', 'sd-di'],
        summary: 'Splitting an app into modules: kinds of module, SPM, linking, acyclic graphs, cross-feature navigation and build speed.',
        lessons: [
            ['sd-modular-why', 'Why modularise, and when not to', { minutes: 15 }],
            ['sd-modular-module-types', 'Module types: feature, core, UI and interface'],
            ['sd-modular-spm', 'SPM packages, products and targets', { minutes: 25, tracks: ['ios'] }],
            ['sd-modular-static-dynamic', 'Static vs dynamic frameworks: launch and size', { minutes: 25, tracks: ['ios'], level: 'advanced' }],
            ['sd-modular-dependency-graph', 'Dependency graphs without cycles'],
            ['sd-modular-feature-navigation', 'Cross-feature navigation: route registries and interfaces', { minutes: 25 }],
            ['sd-modular-demo-apps', 'Feature demo apps', { minutes: 15 }],
            ['sd-modular-build-speed', 'Faster builds: measuring, then interface modules', { minutes: 25, level: 'advanced' }],
            ['sd-modular-tooling', 'Tuist, XcodeGen and Bazel at scale', { minutes: 25, tracks: ['ios'], level: 'advanced' }],
            ['sd-modular-migration', 'Splitting an existing app into modules', { minutes: 25 }],
        ],
    },
    {
        id: 'sd-design-systems', code: 'D62', part: 9, title: 'Design systems', level: 'intermediate', tracks: ['core'], requires: ['sd-swiftui', 'sd-a11y-l10n', 'sd-modularisation'],
        summary: 'Tokens, SwiftUI and UIKit component libraries, theming, Dynamic Type and accessibility built in, docs, and adoption.',
        lessons: [
            ['sd-ds-what', 'What a design system is, and who it serves', { minutes: 15 }],
            ['sd-ds-tokens', 'Design tokens: colour, type, spacing and motion', { minutes: 25 }],
            ['sd-ds-swiftui-components', 'Building a component library in SwiftUI', { minutes: 25, tracks: ['ios'] }],
            ['sd-ds-uikit-components', 'UIKit components alongside SwiftUI', { tracks: ['ios'] }],
            ['sd-ds-theming', 'Theming and dark mode'],
            ['sd-ds-dynamic-type', 'Dynamic Type in components', { tracks: ['ios'] }],
            ['sd-ds-accessibility', 'Accessibility built into components'],
            ['sd-ds-testing', 'Testing a component library'],
            ['sd-ds-docs-catalogs', 'DocC and preview catalogs', { tracks: ['ios'] }],
            ['sd-ds-versioning', 'Versioning and adoption across teams', { level: 'advanced' }],
        ],
    },
    {
        id: 'sd-large-codebases', code: 'D63', part: 9, title: 'Large-codebase engineering', level: 'advanced', tracks: ['lead'], requires: ['sd-modularisation', 'sd-release'],
        summary: 'Repos, ownership, code generation, linting and enforced architecture rules, written decisions, debt and platform teams.',
        lessons: [
            ['sd-lcb-growth', 'Conway\'s law and growing codebases', { minutes: 15 }],
            ['sd-lcb-monorepo-polyrepo', 'Monorepo vs polyrepo'],
            ['sd-lcb-ownership', 'Ownership and team boundaries'],
            ['sd-lcb-codegen', 'Code generation: macros, Sourcery and SwiftGen', { minutes: 25, tracks: ['core'], level: 'intermediate' }],
            ['sd-lcb-lint-format', 'SwiftLint and swift-format', { minutes: 15, tracks: ['core'], level: 'intermediate' }],
            ['sd-lcb-architecture-rules', 'Enforcing architecture rules automatically', { minutes: 25, tracks: ['core'] }],
            ['sd-lcb-docs-decisions', 'Writing it down: DocC, ADRs and RFCs'],
            ['sd-lcb-tech-debt', 'Managing technical debt at scale'],
            ['sd-lcb-platform-teams', 'Platform teams and internal SDKs'],
        ],
    },
    {
        id: 'sd-cross-platform', code: 'D64', part: 9, title: 'Cross-platform, hybrid & multi-app', level: 'advanced', tracks: ['lead'], requires: ['sd-modularisation'],
        summary: 'Native vs cross-platform frameworks, shared logic, web views, Mac and multiplatform targets, multi-brand apps, App Clips and super apps.',
        lessons: [
            ['sd-xplat-options', 'Native vs Kotlin Multiplatform vs Flutter vs React Native', { minutes: 30 }],
            ['sd-xplat-choosing', 'Choosing a cross-platform strategy'],
            ['sd-xplat-shared-logic', 'Sharing business logic across platforms', { minutes: 25 }],
            ['sd-xplat-webviews', 'WKWebView and JavaScript bridges', { minutes: 25, tracks: ['core'], level: 'intermediate' }],
            ['sd-xplat-hybrid-screens', 'Mixing native, web and cross-platform screens'],
            ['sd-xplat-catalyst', 'Mac Catalyst and multiplatform SwiftUI', { tracks: ['core'], level: 'intermediate' }],
            ['sd-xplat-white-label', 'White-label and multi-brand apps', { minutes: 25, tracks: ['core'], level: 'intermediate' }],
            ['sd-xplat-app-clips', 'App Clips', { minutes: 15, tracks: ['core'], level: 'intermediate' }],
            ['sd-xplat-super-apps', 'Super apps and mini-app platforms', { minutes: 25 }],
        ],
    },
    {
        id: 'sd-sdk-design', code: 'D65', part: 9, title: 'SDK & library design', level: 'advanced', tracks: ['lead'], requires: ['sd-swift-design', 'sd-privacy', 'sd-modularisation'],
        summary: 'Designing libraries other apps depend on: API style, evolution, binary stability, setup, threading, privacy, docs and distribution.',
        lessons: [
            ['sd-sdk-good-sdk', 'What makes an SDK pleasant to adopt', { minutes: 15 }],
            ['sd-sdk-api-guidelines', 'The Swift API Design Guidelines', { minutes: 25, tracks: ['core'], level: 'intermediate' }],
            ['sd-sdk-surface-evolution', 'Public surface and evolution: semver and deprecation', { minutes: 25, tracks: ['core'] }],
            ['sd-sdk-abi-xcframeworks', 'ABI and module stability, and XCFrameworks', { minutes: 25, tracks: ['core'] }],
            ['sd-sdk-dependencies', 'Keeping dependencies minimal', { minutes: 15 }],
            ['sd-sdk-initialisation', 'Initialisation and configuration', { tracks: ['core'] }],
            ['sd-sdk-thread-safety', 'Thread-safety guarantees', { tracks: ['core'] }],
            ['sd-sdk-privacy-signing', 'Privacy manifests and SDK signing', { minutes: 15, tracks: ['core'] }],
            ['sd-sdk-docs-samples', 'Docs and sample apps', { minutes: 15 }],
            ['sd-sdk-distribution', 'Distribution: SPM and binary targets', { tracks: ['core'] }],
        ],
    },
];
