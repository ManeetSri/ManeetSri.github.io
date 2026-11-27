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
import arrays from './problems/arrays.js';
import matrices from './problems/matrices.js';
import prefixSums from './problems/prefix-sums.js';
import twoPointers from './problems/two-pointers.js';
import slidingWindow from './problems/sliding-window.js';
import stringsBasic from './problems/strings-basic.js';
import hashing from './problems/hashing.js';
import linkedLists from './problems/linked-lists.js';
import stacks from './problems/stacks.js';
import queues from './problems/queues.js';
import binarySearch from './problems/binary-search.js';
import bsOnAnswer from './problems/bs-on-answer.js';
import elementarySorts from './problems/elementary-sorts.js';
import efficientSorts from './problems/efficient-sorts.js';
import linearSorts from './problems/linear-sorts.js';
import intervals from './problems/intervals.js';
import treeBasics from './problems/tree-basics.js';
import treeTraversals from './problems/tree-traversals.js';
import binaryTrees from './problems/binary-trees.js';
import bst from './problems/bst.js';
import balancedTrees from './problems/balanced-trees.js';
import heaps from './problems/heaps.js';
import tries from './problems/tries.js';
import graphBasics from './problems/graph-basics.js';
import graphTraversals from './problems/graph-traversals.js';
import topoSort from './problems/topo-sort.js';
import shortestPaths from './problems/shortest-paths.js';
import unionFind from './problems/union-find.js';
import mst from './problems/mst.js';
import advancedGraphs from './problems/advanced-graphs.js';
import backtracking from './problems/backtracking.js';
import divideConquer from './problems/divide-conquer.js';
import greedy from './problems/greedy.js';
import dpFoundations from './problems/dp-foundations.js';
import dpGrids from './problems/dp-grids.js';
import dpKnapsack from './problems/dp-knapsack.js';
import dpStrings from './problems/dp-strings.js';
import dpLis from './problems/dp-lis.js';
import dpIntervals from './problems/dp-intervals.js';
import dpStates from './problems/dp-states.js';
import dpAdvanced from './problems/dp-advanced.js';
import patterns from './problems/patterns.js';

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
    ...arrays,
    ...matrices,
    ...prefixSums,
    ...twoPointers,
    ...slidingWindow,
    ...stringsBasic,
    ...hashing,
    ...linkedLists,
    ...stacks,
    ...queues,
    ...binarySearch,
    ...bsOnAnswer,
    ...elementarySorts,
    ...efficientSorts,
    ...linearSorts,
    ...intervals,
    ...treeBasics,
    ...treeTraversals,
    ...binaryTrees,
    ...bst,
    ...balancedTrees,
    ...heaps,
    ...tries,
    ...graphBasics,
    ...graphTraversals,
    ...topoSort,
    ...shortestPaths,
    ...unionFind,
    ...mst,
    ...advancedGraphs,
    ...backtracking,
    ...divideConquer,
    ...greedy,
    ...dpFoundations,
    ...dpGrids,
    ...dpKnapsack,
    ...dpStrings,
    ...dpLis,
    ...dpIntervals,
    ...dpStates,
    ...dpAdvanced,
    ...patterns,
];

export const problemById = Object.fromEntries(problems.map((problem) => [problem.id, problem]));
