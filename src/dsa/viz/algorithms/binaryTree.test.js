import { test } from 'node:test';
import assert from 'node:assert/strict';
import { binaryTreeFrames, treeFromLevelOrder } from './binaryTree.js';

const shape = (tree, id = tree.root) => (id === null ? null : [tree.nodes[id].value, shape(tree, tree.nodes[id].left), shape(tree, tree.nodes[id].right)]);

test('trees build from level order with null gaps, like TreeNode.make', () => {
    assert.deepEqual(shape(treeFromLevelOrder([3, 9, 20, null, null, 15, 7])), [3, [9, null, null], [20, [15, null, null], [7, null, null]]]);
    assert.deepEqual(shape(treeFromLevelOrder([1, null, 2, null, 3])), [1, null, [2, null, [3, null, null]]]);
    assert.equal(treeFromLevelOrder([]).root, null);
    assert.equal(treeFromLevelOrder([null]).root, null);
});

test('traversals visit any tree in the right order', () => {
    const tree = [1, 2, 3, 4, 5, null, 6, null, null, 7];
    const orders = { preorder: [1, 2, 4, 5, 7, 3, 6], inorder: [4, 2, 7, 5, 1, 3, 6], postorder: [4, 7, 5, 2, 6, 3, 1], levelorder: [1, 2, 3, 4, 5, 6, 7] };
    Object.entries(orders).forEach(([order, expected]) => {
        assert.deepEqual(binaryTreeFrames('traversal', { tree, order }).at(-1).output, expected, order);
    });
    assert.deepEqual(binaryTreeFrames('iterativeInorder', { tree }).at(-1).output, orders.inorder);
    assert.deepEqual(binaryTreeFrames('iterativeInorder', { tree: [1, null, 2, 3] }).at(-1).output, [1, 3, 2]);
});

test('diameter counts edges, and returned heights are kept as notes', () => {
    const frames = binaryTreeFrames('diameter', { tree: [1, 2, 3, 4, 5, null, 6, null, null, 7] });
    assert.equal(frames.at(-1).vars.best, 5);
    assert.equal(frames.at(-1).tree.nodes[0].note, 4);
    assert.equal(binaryTreeFrames('diameter', { tree: [1] }).at(-1).vars.best, 0);
    // The longest path can avoid the root
    assert.equal(binaryTreeFrames('diameter', { tree: [1, 2, null, 3, 4, 5, null, null, 6, 7, null, null, 8] }).at(-1).vars.best, 6);
});

test('lca finds the lowest common ancestor, including a node that is its own ancestor', () => {
    const tree = [3, 5, 1, 6, 2, 0, 8, null, null, 7, 4];
    const answer = (p, q) => {
        const last = binaryTreeFrames('lca', { tree, p, q }).at(-1);
        const id = Object.keys(last.marks).find((key) => last.marks[key] === 'swap');
        return last.tree.nodes[id].value;
    };
    assert.equal(answer(7, 8), 3);
    assert.equal(answer(7, 4), 2);
    assert.equal(answer(5, 4), 5);
    assert.equal(answer(6, 0), 3);
});
