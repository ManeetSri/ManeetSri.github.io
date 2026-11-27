import { useMemo } from 'react';
import Player from '../Player.jsx';
import TreeDiagram from './TreeDiagram.jsx';
import { AVL_CODE, avlFrames, bstFrames, bstProgram, HEAP_CODE, heapAsTree, heapFrames, TRIE_CODE, trieFrames } from '../algorithms/trees.js';

const useStable = (value) => {
    const key = JSON.stringify(value ?? null);
    return useMemo(() => JSON.parse(key), [key]);
};

const Output = ({ values }) => (values ? (
    <p className="mt-3 font-mono text-xs text-muted">output: <span className="text-amber">{values.join(', ') || '—'}</span></p>
) : null);

// ```visual bst with { program: insert | search | remove | traversal, input: { values, target, order } }
export const BstView = ({ program = 'insert', input }) => {
    const stableInput = useStable(input);
    const { title, code } = bstProgram(program, stableInput ?? {});
    const frames = useMemo(() => bstFrames(program, stableInput ?? {}), [program, stableInput]);
    return (
        <Player frames={frames} code={code} title={title}>
            {(frame) => (
                <div>
                    <TreeDiagram tree={frame.tree} marks={frame.marks} label="Binary search tree" />
                    <Output values={frame.output} />
                </div>
            )}
        </Player>
    );
};

// ```visual avl with { values: [...] }
export const AvlView = ({ values }) => {
    const stableValues = useStable(values);
    const frames = useMemo(() => avlFrames(stableValues ? { values: stableValues } : {}), [stableValues]);
    return (
        <Player frames={frames} code={AVL_CODE} title="AVL insertion with rotations">
            {(frame) => <TreeDiagram tree={frame.tree} marks={frame.marks} label="AVL tree with balance factors" />}
        </Player>
    );
};

// ```visual heap with { operations: [5, 3, 8, "pop"] }
export const HeapView = ({ operations }) => {
    const stableOps = useStable(operations);
    const frames = useMemo(() => heapFrames(stableOps ? { operations: stableOps } : {}), [stableOps]);
    return (
        <Player frames={frames} code={HEAP_CODE} title="A min-heap: the same data as an array and as a tree">
            {(frame) => (
                <div className="space-y-4">
                    <TreeDiagram tree={heapAsTree(frame.items)} marks={frame.marks} label="Heap as a tree" />
                    <ol className="flex min-w-max gap-1.5 overflow-x-auto" aria-label="Heap as an array">
                        {frame.items.map((value, index) => (
                            <li key={index} className="flex w-10 flex-col items-center gap-1">
                                <span className={`flex h-10 w-10 items-center justify-center rounded-lg border font-mono text-sm ${frame.marks[index] === 'swap' ? 'border-amber bg-amber/20 text-amber' : frame.marks[index] === 'found' ? 'border-[#30D158] bg-[#30D158]/20 text-[#30D158]' : frame.marks[index] === 'out' ? 'border-[#FF9D96] text-[#FF9D96]' : 'border-line'}`}>{value}</span>
                                <span className="font-mono text-[10px] text-muted">{index}</span>
                            </li>
                        ))}
                        {frame.items.length === 0 && <li className="font-mono text-xs text-muted">[]</li>}
                    </ol>
                </div>
            )}
        </Player>
    );
};

// ```visual trie with { words: [...], prefix: "ca" }
export const TrieView = ({ words, prefix }) => {
    const stableWords = useStable(words);
    const frames = useMemo(() => trieFrames({ ...(stableWords ? { words: stableWords } : {}), ...(prefix ? { prefix } : {}) }), [stableWords, prefix]);
    return (
        <Player frames={frames} code={TRIE_CODE} title="A trie: words that share a prefix share a path">
            {(frame) => (
                <TreeDiagram
                    tree={{ root: '0', nodes: frame.nodes }}
                    marks={frame.marks}
                    childrenOf={(id) => Object.entries(frame.nodes[id].children).sort(([a], [b]) => a.localeCompare(b)).map(([, child]) => String(child))}
                    badge={(node) => node.isWord}
                    label="Trie; green dots mark the ends of words"
                />
            )}
        </Player>
    );
};
