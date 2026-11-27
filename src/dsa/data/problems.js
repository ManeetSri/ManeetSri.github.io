// Every practice problem. Statements and solutions live in src/dsa/content/problems/<id>.mdx, and each
// problem's tests live in the companion Swift package as `swiftTest`, run with `swift test --filter <swiftTest>`.
// Statements are written fresh. `similar` can point to a comparable problem elsewhere for extra practice.

import orientation from './problems/orientation.js';
import swiftFirstSteps from './problems/swift-first-steps.js';
import swiftTypesOperators from './problems/swift-types-operators.js';
import swiftControlFlow from './problems/swift-control-flow.js';
import swiftOptionals from './problems/swift-optionals.js';
import swiftFunctions from './problems/swift-functions.js';
import swiftClosures from './problems/swift-closures.js';
import swiftCollections from './problems/swift-collections.js';
import swiftStrings from './problems/swift-strings.js';
import swiftTypes from './problems/swift-types.js';
import swiftGenerics from './problems/swift-generics.js';
import swiftMemory from './problems/swift-memory.js';
import swiftTooling from './problems/swift-tooling.js';
import problemSolving from './problems/problem-solving.js';
import complexity from './problems/complexity.js';
import mathBasics from './problems/math-basics.js';
import bits from './problems/bits.js';
import recursion from './problems/recursion.js';

export const DIFFICULTIES = {
    warmup: { label: 'Warm-up', xp: 15 },
    easy: { label: 'Easy', xp: 30 },
    medium: { label: 'Medium', xp: 60 },
    hard: { label: 'Hard', xp: 120 },
    challenge: { label: 'Challenge', xp: 200 },
};

export const PATTERNS = {
    basics: 'Swift basics',
    traversal: 'Linear scan',
    'two-pointers': 'Two pointers',
    'sliding-window': 'Sliding window',
    'prefix-sum': 'Prefix sum',
    hashing: 'Hashing',
    'binary-search': 'Binary search',
    'fast-slow': 'Fast & slow pointers',
    'monotonic-stack': 'Monotonic stack',
    heap: 'Heap / top K',
    bfs: 'BFS',
    dfs: 'DFS',
    backtracking: 'Backtracking',
    greedy: 'Greedy',
    dp: 'Dynamic programming',
    'union-find': 'Union-find',
    trie: 'Trie',
    'topo-sort': 'Topological sort',
    intervals: 'Intervals',
    bits: 'Bit manipulation',
    math: 'Maths',
    design: 'Design',
    strings: 'Strings',
    recursion: 'Recursion',
    simulation: 'Simulation',
    sorting: 'Sorting',
    matrix: 'Matrix / grid',
};

// Curated lists the problem bank can filter by
export const LISTS = {
    core75: 'Core 75',
    patterns150: 'Patterns 150',
    swift: 'Swift-specific',
};

// Every problem, gathered from one file per module in ./problems/<module>.js. Each problem:
//   id          permanent, unique slug; the statement lives in src/dsa/content/problems/<id>.mdx
//   title, difficulty (DIFFICULTIES), patterns (PATTERNS), lists (LISTS), minutes (a rough estimate)
//   lessons     the lesson ids it practises; lessons list their problems from this field
//   swiftTest   the Swift Testing suite in dsa-swift/Tests, run with `swift test --filter <swiftTest>`
//   similar     optional { label, url } pointing to a comparable problem elsewhere
export const problems = [
    ...orientation,
    ...swiftFirstSteps,
    ...swiftTypesOperators,
    ...swiftControlFlow,
    ...swiftOptionals,
    ...swiftFunctions,
    ...swiftClosures,
    ...swiftCollections,
    ...swiftStrings,
    ...swiftTypes,
    ...swiftGenerics,
    ...swiftMemory,
    ...swiftTooling,
    ...problemSolving,
    ...complexity,
    ...mathBasics,
    ...bits,
    ...recursion,
];

export const problemById = Object.fromEntries(problems.map((problem) => [problem.id, problem]));
