// Where each course keeps its content, data and Swift package, for the content scripts and the build plugin
import { sep } from 'node:path';

export const COURSES = {
    dsa: {
        id: 'dsa',
        title: 'DSA',
        base: '/dsa',
        idPrefix: '',
        data: 'src/dsa/data/courseData.js',
        exportName: 'dsaData',
        contentDir: 'src/dsa/content',
        lessonsDir: 'src/dsa/content/lessons',
        sheetsDir: 'src/dsa/content/sheets',
        // The folder of statement files for each kind of practice item
        practiceDirs: { problem: 'src/dsa/content/problems' },
        registryDirs: ['src/dsa/data/problems'],
        packageDir: 'dsa-swift',
        swiftVersion: '5',
        fixedLists: { core75: 75, patterns150: 150 },
    },
    design: {
        id: 'design',
        title: 'System design',
        base: '/design',
        idPrefix: 'sd-',
        data: 'src/dsa/design/data/courseData.js',
        exportName: 'designData',
        contentDir: 'src/dsa/design/content',
        lessonsDir: 'src/dsa/design/content/lessons',
        sheetsDir: 'src/dsa/design/content/sheets',
        practiceDirs: { problem: 'src/dsa/design/content/katas', design: 'src/dsa/design/content/designs', critique: 'src/dsa/design/content/critiques' },
        registryDirs: ['src/dsa/design/data/katas', 'src/dsa/design/data/exercises'],
        packageDir: 'design-swift',
        // Strict concurrency is part of what this course teaches
        swiftVersion: '6',
        // Checked once the lists are complete, in the last delivery phase
        fixedLists: {},
    },
};

// Type-checking iOS-only code (UIKit, WidgetKit…) needs the iOS simulator SDK, which comes with Xcode
export const IOS_TARGET = 'arm64-apple-ios18.0-simulator';

export const courseOfPath = (path) => (String(path ?? '').split(sep).join('/').includes('/src/dsa/design/') ? 'design' : 'dsa');

// `--course <id>`, or every course
export const coursesFromArgs = (args) => {
    const index = args.indexOf('--course');
    if (index < 0) return Object.values(COURSES);
    const course = COURSES[args[index + 1]];
    if (!course) throw new Error(`Unknown course "${args[index + 1]}" (use ${Object.keys(COURSES).join(' or ')})`);
    return [course];
};
