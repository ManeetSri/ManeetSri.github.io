// Design exercises and architecture reviews for D04 · SOLID in Swift
export default [
    {
        id: 'sd-review-solid-profile-screen',
        kind: 'critique',
        title: 'Review: the profile screen',
        difficulty: 'medium',
        patterns: ['principles', 'ui', 'architecture'],
        lessons: ['sd-solid-applied', 'sd-solid-srp', 'sd-solid-lsp'],
        minutes: 25,
        summary: 'A profile view controller and its guest subclass. Name each SOLID principle it breaks, and what each break costs.',
    },
    {
        id: 'sd-review-solid-upload-service',
        kind: 'critique',
        title: 'Review: the upload service',
        difficulty: 'hard',
        patterns: ['principles', 'networking', 'architecture'],
        lessons: ['sd-solid-applied', 'sd-solid-ocp', 'sd-solid-isp', 'sd-solid-dip'],
        minutes: 30,
        summary: 'A shared upload service with a Wi-Fi-only subclass and a five-method observer protocol. Find the design problems behind its bugs.',
    },
];
