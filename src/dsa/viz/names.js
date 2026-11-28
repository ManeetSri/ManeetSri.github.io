// Every visualiser a lesson can embed with a ```visual <name> block. The build checks names against
// this list, viz/registry.js loads each one on demand, and src/dsa/content/AUTHORING.md documents the props.
import { SCRIPT_NAMES } from './script/index.js';
import { SIM_NAMES } from './sims/index.js';

export const VISUAL_NAMES = [
    'binarySearch', 'answerSearch', 'recursionTree', 'traceTable', 'growthChart', 'bitPlayground',
    'arrayTrace', 'linkedList', 'stackQueue', 'hashTable', 'intervals',
    'bst', 'binaryTree', 'avl', 'heap', 'trie',
    'graph', 'grid', 'matrix', 'unionFind',
    'dpTable', 'nQueens', 'subsetsTree', 'huffman',
    'segmentTree', 'fenwick',
    ...SCRIPT_NAMES, ...SIM_NAMES,
];
