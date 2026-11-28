// Algorithms on any binary tree, built from a level-order array with nulls for missing children (the same
// form as DSAKit's TreeNode.make). Frames use the tree snapshots of trees.js: { tree, marks, line, message,
// output?, stack?, vars? }, where a node's `note` shows a value it returned.
import { BST_CODE, traversalFrames } from './trees.js';

const clone = (tree) => ({ root: tree.root, nodes: Object.fromEntries(Object.entries(tree.nodes).map(([id, node]) => [id, { ...node }])) });

// Node ids are positions in level order, so they're stable and easy to read in tests
export const treeFromLevelOrder = (levelOrder) => {
    const tree = { root: null, nodes: {} };
    if (!levelOrder.length || levelOrder[0] === null) return tree;
    tree.nodes[0] = { value: levelOrder[0], left: null, right: null };
    tree.root = 0;
    const parents = [0];
    let head = 0;
    let index = 1;
    while (index < levelOrder.length && head < parents.length) {
        const parent = parents[head];
        head += 1;
        for (const side of ['left', 'right']) {
            if (index < levelOrder.length && levelOrder[index] !== null) {
                tree.nodes[index] = { value: levelOrder[index], left: null, right: null };
                tree.nodes[parent][side] = index;
                parents.push(index);
            }
            index += 1;
        }
    }
    return tree;
};

const DEFAULT_TREE = [1, 2, 3, 4, 5, null, 6, null, null, 7];

const CODE = {
    iterativeInorder: `func inorder(_ root: TreeNode?) -> [Int] {
    var result: [Int] = []
    var stack: [TreeNode] = []
    var current = root
    while current != nil || !stack.isEmpty {
        while let node = current {
            stack.append(node)
            current = node.left
        }
        let node = stack.removeLast()
        result.append(node.value)
        current = node.right
    }
    return result
}`,
    diameter: `func diameter(_ root: TreeNode?) -> Int {
    var best = 0
    func height(_ node: TreeNode?) -> Int {
        guard let node else { return 0 }
        let left = height(node.left)
        let right = height(node.right)
        best = max(best, left + right)       // the longest path through node, in edges
        return 1 + max(left, right)
    }
    _ = height(root)
    return best
}`,
    lca: `func lowestCommonAncestor(_ root: TreeNode?, _ p: TreeNode, _ q: TreeNode) -> TreeNode? {
    guard let root else { return nil }
    if root === p || root === q { return root }
    let left = lowestCommonAncestor(root.left, p, q)
    let right = lowestCommonAncestor(root.right, p, q)
    if left != nil && right != nil { return root }   // p and q are on different sides
    return left ?? right
}`,
};

function* iterativeInorder({ tree: levelOrder }) {
    const tree = treeFromLevelOrder(levelOrder);
    const { nodes } = tree;
    const stack = [];
    const output = [];
    const visited = new Set();
    let current = tree.root;
    const frame = (line, message, focus) => ({
        tree,
        marks: { ...Object.fromEntries([...visited].map((id) => [id, 'found'])), ...Object.fromEntries(stack.map((id) => [id, 'path'])), ...(focus !== null && focus !== undefined ? { [focus]: 'swap' } : {}) },
        stack: stack.map((id) => String(nodes[id].value)),
        output: [...output],
        line,
        message,
    });
    yield frame(4, 'current starts at the root, and the stack is empty. The stack remembers the nodes whose left side we’re still exploring.', current);
    while (current !== null || stack.length) {
        while (current !== null) {
            stack.push(current);
            const pushed = current;
            current = nodes[current].left;
            yield frame(7, `Push ${nodes[pushed].value} and go left${current === null ? ': there’s nothing there' : ` to ${nodes[current].value}`}.`, pushed);
        }
        const id = stack.pop();
        output.push(nodes[id].value);
        visited.add(id);
        yield frame(11, `Nothing further left, so pop ${nodes[id].value} and visit it.`, id);
        current = nodes[id].right;
        yield frame(12, current === null ? `${nodes[id].value} has no right child. ${stack.length ? `The stack’s top, ${nodes[stack.at(-1)].value}, is next.` : 'The stack is empty too.'}` : `Now explore ${nodes[id].value}’s right subtree, starting at ${nodes[current].value}.`, current);
    }
    yield frame(14, `Inorder: ${output.join(', ')}. Every node is pushed and popped once: O(n) time, O(h) stack.`, null);
}

function* diameter({ tree: levelOrder }) {
    const tree = treeFromLevelOrder(levelOrder);
    const { nodes } = tree;
    const done = new Set();
    let best = 0;
    let bestAt = null;
    const frame = (line, message, focus) => ({
        tree: clone(tree),
        marks: { ...Object.fromEntries([...done].map((id) => [id, 'path'])), ...(bestAt !== null ? { [bestAt]: 'found' } : {}), ...(focus !== undefined ? { [focus]: 'swap' } : {}) },
        vars: { best },
        line,
        message,
    });
    yield frame(2, 'Each call returns its subtree’s height, and on the way it checks the longest path that bends at that node: left height + right height edges.');
    const height = function* walk(id) {
        if (id === null) return 0;
        const left = yield* walk(nodes[id].left);
        const right = yield* walk(nodes[id].right);
        const through = left + right;
        const record = through > best;
        if (record) {
            best = through;
            bestAt = id;
        }
        nodes[id].note = 1 + Math.max(left, right);
        done.add(id);
        yield frame(8, `At ${nodes[id].value}: left height ${left}, right height ${right}. A path bending here has ${through} edge${through === 1 ? '' : 's'}${record ? ', a new best' : ''}. Return height ${nodes[id].note}.`, id);
        return nodes[id].note;
    };
    yield* height(tree.root);
    yield frame(11, `The diameter is ${best} edge${best === 1 ? '' : 's'}, through ${bestAt === null ? 'no node' : nodes[bestAt].value} (green). One post-order pass: O(n).`);
}

function* lca({ tree: levelOrder, p, q }) {
    const tree = treeFromLevelOrder(levelOrder);
    const { nodes } = tree;
    const idOf = (value) => Object.keys(nodes).map(Number).find((id) => nodes[id].value === value);
    const pId = idOf(p);
    const qId = idOf(q);
    if (pId === undefined || qId === undefined) throw new Error('p and q must both be values in the tree');
    const targets = { [pId]: 'found', [qId]: 'found' };
    const frame = (line, message, focus) => ({ tree: clone(tree), marks: { ...targets, ...(focus !== undefined ? { [focus]: 'swap' } : {}) }, line, message });
    yield frame(1, `Find the lowest common ancestor of ${p} and ${q} (green). Each call returns p, q, their ancestor, or nil, shown beside the node.`);
    const walk = function* visit(id) {
        if (id === null) return null;
        const { value } = nodes[id];
        if (id === pId || id === qId) {
            nodes[id].note = value;
            yield frame(3, `${value} is one of the targets: return it straight away. Anything below it doesn’t matter.`, id);
            return id;
        }
        yield frame(4, `At ${value}: search both sides.`, id);
        const left = yield* visit(nodes[id].left);
        const right = yield* visit(nodes[id].right);
        if (left !== null && right !== null) {
            nodes[id].note = value;
            yield frame(6, `Both sides found something: ${nodes[left].value} on the left and ${nodes[right].value} on the right. So ${value} is the lowest common ancestor.`, id);
            return id;
        }
        const found = left ?? right;
        nodes[id].note = found === null ? 'nil' : nodes[found].value;
        yield frame(7, found === null ? `Neither side of ${value} holds p or q: return nil.` : `Only one side found something, so pass ${nodes[found].value} up.`, id);
        return found;
    };
    const answer = yield* walk(tree.root);
    yield { ...frame(7, `The answer is ${nodes[answer].value}. Every node is visited at most once: O(n).`), marks: { ...targets, [answer]: 'swap' } };
}

const PROGRAMS = {
    traversal: { title: 'Tree traversal', code: (input) => BST_CODE[input.order], defaults: { tree: DEFAULT_TREE, order: 'preorder' }, run: ({ tree, order }) => traversalFrames(treeFromLevelOrder(tree), order) },
    iterativeInorder: { title: 'Inorder traversal with an explicit stack', code: () => CODE.iterativeInorder, defaults: { tree: DEFAULT_TREE }, run: iterativeInorder },
    diameter: { title: 'Height and diameter in one pass', code: () => CODE.diameter, defaults: { tree: DEFAULT_TREE }, run: diameter },
    lca: { title: 'Lowest common ancestor', code: () => CODE.lca, defaults: { tree: [3, 5, 1, 6, 2, 0, 8, null, null, 7, 4], p: 7, q: 8 }, run: lca },
};

export const BINARY_TREE_PROGRAMS = Object.keys(PROGRAMS);

export const binaryTreeProgram = (name, input = {}) => {
    const program = PROGRAMS[name];
    if (!program) throw new Error(`Unknown binaryTree program "${name}" (known: ${BINARY_TREE_PROGRAMS.join(', ')})`);
    const merged = { ...program.defaults, ...input };
    return { title: program.title, code: program.code(merged), input: merged, run: program.run };
};

export const binaryTreeFrames = (name, input = {}) => {
    const { run, input: merged } = binaryTreeProgram(name, input);
    return [...run(merged)];
};
