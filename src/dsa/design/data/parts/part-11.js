// Part XI: Leadership & capstones (D74–D75).
// Leading architecture on a team (docs, decisions, reviews, migrations, strategy, mentoring), then seven
// capstone projects that pull the whole course together. Outline only: titles, no content.

export default [
    {
        id: 'sd-leadership', code: 'D74', part: 11, title: 'Architecture leadership', level: 'expert', tracks: ['lead'], requires: ['sd-arch-evolution', 'sd-diagrams', 'sd-large-codebases'],
        summary: 'Writing and reviewing designs, recording decisions, planning big changes, setting technical direction and growing the engineers around you.',
        lessons: [
            ['sd-lead-role', 'What an architect does on a mobile team', { minutes: 15 }],
            ['sd-lead-design-docs', 'Writing design docs people read', { minutes: 25 }],
            ['sd-lead-rfcs', 'Running an RFC process', { minutes: 20 }],
            ['sd-lead-adrs', 'Keeping an ADR log the team uses', { minutes: 20 }],
            ['sd-lead-trade-offs', 'Presenting trade-offs to engineers and stakeholders', { minutes: 20 }],
            ['sd-lead-reviews', 'Reviewing designs and code at architecture level', { minutes: 30 }],
            ['sd-lead-migrations', 'Planning large changes and migrations', { minutes: 25 }],
            ['sd-lead-strategy', 'Technical strategy and roadmaps', { minutes: 25 }],
            ['sd-lead-governance', 'Lightweight architecture governance', { minutes: 20 }],
            ['sd-lead-mentoring', 'Mentoring and growing engineers', { minutes: 20 }],
        ],
    },
    {
        id: 'sd-capstones', code: 'D75', part: 11, title: 'Capstone projects', level: 'advanced', tracks: ['core'],
        requires: ['sd-clean', 'sd-offline-sync', 'sd-realtime', 'sd-testing', 'sd-modularisation', 'sd-sdk-design'],
        summary: 'Seven projects that put the course to work: apps, packages and SDKs built end to end, plus a design-doc portfolio.',
        lessons: [
            ['sd-cap-intro', 'How the capstone projects work', { minutes: 30 }],
            ['sd-cap-clean-app', 'A modular Clean SwiftUI app with DI and full tests', { minutes: 40 }],
            ['sd-cap-offline-notes', 'Offline-first notes with sync and conflict resolution', { minutes: 40, level: 'expert' }],
            ['sd-cap-network-images', 'A networking and image-pipeline package', { minutes: 40 }],
            ['sd-cap-tca-feature', 'A TCA-style feature with exhaustive tests', { minutes: 35, tracks: ['deep'] }],
            ['sd-cap-flags-analytics', 'A feature-flag and analytics SDK', { minutes: 40, tracks: ['deep'] }],
            ['sd-cap-chat-outbox', 'A WebSocket chat client with an outbox', { minutes: 40, level: 'expert' }],
            ['sd-cap-design-portfolio', 'A design-doc and ADR portfolio for one case study', { minutes: 35, tracks: ['lead'], level: 'expert' }],
        ],
    },
];
