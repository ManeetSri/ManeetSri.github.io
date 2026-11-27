import { useMemo } from 'react';
import Player from '../Player.jsx';
import TreeDiagram from './TreeDiagram.jsx';
import { AVL_CODE, avlFrames, bstFrames, bstProgram, HEAP_CODE, HEAP_SORT_CODE, HEAPIFY_CODE, heapAsTree, heapFrames, heapifyFrames, heapSortFrames, TRIE_CODE, TRIE_REMOVE_CODE, trieFrames } from '../algorithms/trees.js';
import { binaryTreeFrames, binaryTreeProgram } from '../algorithms/binaryTree.js';

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

const HEAP_PROGRAMS = {
    operations: { code: HEAP_CODE, title: 'A min-heap: the same data as an array and as a tree', frames: (props) => heapFrames(props.operations ? { operations: props.operations } : {}) },
    heapify: { code: HEAPIFY_CODE, title: 'Heapify: sift down from the last parent to the root', frames: (props) => heapifyFrames(props.items ? { items: props.items } : {}) },
    heapSort: { code: HEAP_SORT_CODE, title: 'Heap sort: a max-heap in front, the sorted part behind', frames: (props) => heapSortFrames(props.items ? { items: props.items } : {}) },
};

// ```visual heap with { operations: [5, 3, 8, "pop"] }, or { program: heapify | heapSort, items: [...] }
export const HeapView = ({ program = 'operations', operations, items }) => {
    const props = useStable({ operations, items });
    const spec = HEAP_PROGRAMS[program] ?? HEAP_PROGRAMS.operations;
    const frames = useMemo(() => spec.frames(props), [spec, props]);
    return (
        <Player frames={frames} code={spec.code} title={spec.title}>
            {(frame) => (
                <div className="space-y-4">
                    <TreeDiagram tree={heapAsTree(frame.items.slice(0, frame.heapSize ?? frame.items.length))} marks={frame.marks} label="Heap as a tree" />
                    <ol className="flex min-w-max gap-1.5 overflow-x-auto" aria-label="Heap as an array">
                        {frame.items.map((value, index) => (
                            <li key={index} className="flex w-10 flex-col items-center gap-1">
                                <span className={`flex h-10 w-10 items-center justify-center rounded-lg border font-mono text-sm ${frame.marks[index] === 'swap' ? 'border-amber bg-amber/20 text-amber' : frame.marks[index] === 'found' || index >= (frame.heapSize ?? Infinity) ? 'border-[#30D158] bg-[#30D158]/20 text-[#30D158]' : frame.marks[index] === 'out' ? 'border-[#FF9D96] text-[#FF9D96]' : frame.marks[index] === 'path' ? 'border-amber/60' : 'border-line'}`}>{value}</span>
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

// ```visual trie with { words: [...], prefix: "ca" }, or { words: [...], remove: [...] } to delete with pass counts
export const TrieView = ({ words, prefix, remove }) => {
    const stableWords = useStable(words);
    const stableRemove = useStable(remove);
    const frames = useMemo(() => trieFrames({ ...(stableWords ? { words: stableWords } : {}), ...(prefix ? { prefix } : {}), ...(stableRemove ? { remove: stableRemove } : {}) }), [stableWords, prefix, stableRemove]);
    return (
        <Player frames={frames} code={stableRemove ? TRIE_REMOVE_CODE : TRIE_CODE} title={stableRemove ? 'Removing words from a trie with pass counts' : 'A trie: words that share a prefix share a path'}>
            {(frame) => (
                <TreeDiagram
                    tree={{ root: '0', nodes: frame.nodes }}
                    marks={frame.marks}
                    childrenOf={(id) => Object.entries(frame.nodes[id].children).sort(([a], [b]) => a.localeCompare(b)).map(([, child]) => String(child))}
                    badge={(node) => node.isWord}
                    label={stableRemove ? 'Trie; green dots mark the ends of words, numbers count the words passing through' : 'Trie; green dots mark the ends of words'}
                    plainNotes={Boolean(stableRemove)}
                />
            )}
        </Player>
    );
};

// ```visual binaryTree with { program: traversal | iterativeInorder | diameter | lca, input: { tree: [level order with nulls], order, p, q } }
export const BinaryTreeView = ({ program = 'traversal', input }) => {
    const stableInput = useStable(input);
    const { title, code } = binaryTreeProgram(program, stableInput ?? {});
    const frames = useMemo(() => binaryTreeFrames(program, stableInput ?? {}), [program, stableInput]);
    return (
        <Player frames={frames} code={code} title={title}>
            {(frame) => (
                <div className="space-y-3">
                    <TreeDiagram tree={frame.tree} marks={frame.marks} label="Binary tree" plainNotes />
                    {frame.stack && (
                        <div>
                            <p className="mb-1.5 font-mono text-[11px] uppercase tracking-wider text-muted">Stack (top on the right)</p>
                            <ol className="flex flex-wrap gap-1" aria-label="Stack">
                                {frame.stack.length === 0 && <li className="font-mono text-xs text-muted">empty</li>}
                                {frame.stack.map((label, index) => (
                                    <li key={`${label}-${index}`} className={`rounded-md border px-2.5 py-1 font-mono text-xs ${index === frame.stack.length - 1 ? 'border-amber bg-amber/15 text-amber' : 'border-line'}`}>{label}</li>
                                ))}
                            </ol>
                        </div>
                    )}
                    <Output values={frame.output} />
                    {frame.vars && (
                        <div className="flex flex-wrap gap-2" aria-label="Variables">
                            {Object.entries(frame.vars).map(([name, value]) => (
                                <span key={name} className="rounded-lg border border-line bg-white/[0.04] px-3 py-1.5 font-mono text-xs">
                                    <span className="text-muted">{name}</span> <span className="text-amber">{String(value)}</span>
                                </span>
                            ))}
                        </div>
                    )}
                </div>
            )}
        </Player>
    );
};
