// Every visualiser a lesson can embed with a ```visual <name> block. The build checks names against
// this list, viz/registry.js loads each one on demand, and src/dsa/content/AUTHORING.md documents the props.
export const VISUAL_NAMES = [
    'binarySearch', 'answerSearch', 'recursionTree', 'traceTable', 'growthChart', 'bitPlayground',
    'arrayTrace', 'linkedList', 'stackQueue', 'hashTable', 'intervals',
    'bst', 'avl', 'heap', 'trie',
    'graph', 'grid', 'matrix',
    'dpTable', 'nQueens', 'subsetsTree',
    'segmentTree', 'fenwick',
];
