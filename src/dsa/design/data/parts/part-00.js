// Part 0: Start here (D00). How the course works, what system design and architecture mean on a phone
// rather than a server, the companion Swift package, and the design framework every later lesson,
// exercise and mock interview follows.
//
// A lesson is ['id', 'Title', { options }]. Options default to the module's level and tracks, and
// 20 minutes. Lesson ids are permanent: progress is stored against them.

export default [
    {
        id: 'sd-orientation', code: 'D00', part: 0, title: 'Orientation', level: 'beginner', tracks: ['core'], requires: [],
        summary: 'How the course works, what system design and architecture mean on mobile, the companion package, and the design framework used in every lesson.',
        lessons: [
            ['sd-orientation-course', 'How this course works', { minutes: 15 }],
            ['sd-orientation-mobile', 'System design on mobile, and how it differs from backend'],
            ['sd-orientation-decisions', 'Architecture, design and implementation decisions', { minutes: 15 }],
            ['sd-orientation-companion', 'The companion Swift package'],
            ['sd-orientation-framework', 'The design framework: from requirements to evolution', { minutes: 30 }],
            ['sd-orientation-prompts', 'Reading a design prompt'],
            ['sd-orientation-journal', 'Keeping a design journal', { minutes: 10 }],
        ],
    },
];
