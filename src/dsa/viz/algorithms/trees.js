// Tree algorithms as frames. A tree snapshot is { root, nodes: { id: { value, left, right, note } } },
// where left/right are node ids or null. Frames: { tree, marks: { id: tone }, line, message, output? }.

const clone = (tree) => ({ root: tree.root, nodes: Object.fromEntries(Object.entries(tree.nodes).map(([id, node]) => [id, { ...node }])) });

// ── Binary search trees ────────────────────────────────────────────────────────────────────────

const BST_CODE = {
    insert: `func insert(_ value: Int, into node: TreeNode?) -> TreeNode {
    guard let node else { return TreeNode(value) }
    if value < node.value {
        node.left = insert(value, into: node.left)
    } else if value > node.value {
        node.right = insert(value, into: node.right)
    }
    return node
}`,
    search: `func contains(_ value: Int, in root: TreeNode?) -> Bool {
    var current = root
    while let node = current {
        if value == node.value { return true }
        current = value < node.value ? node.left : node.right
    }
    return false
}`,
    remove: `func remove(_ value: Int, from node: TreeNode?) -> TreeNode? {
    guard let node else { return nil }
    if value < node.value {
        node.left = remove(value, from: node.left)
    } else if value > node.value {
        node.right = remove(value, from: node.right)
    } else {
        guard let left = node.left else { return node.right }
        guard let right = node.right else { return left }
        var successor = right
        while let next = successor.left { successor = next }
        node.value = successor.value
        node.right = remove(successor.value, from: right)
    }
    return node
}`,
    inorder: `func inorder(_ node: TreeNode?, _ visit: (Int) -> Void) {
    guard let node else { return }
    inorder(node.left, visit)
    visit(node.value)
    inorder(node.right, visit)
}`,
    preorder: `func preorder(_ node: TreeNode?, _ visit: (Int) -> Void) {
    guard let node else { return }
    visit(node.value)
    preorder(node.left, visit)
    preorder(node.right, visit)
}`,
    postorder: `func postorder(_ node: TreeNode?, _ visit: (Int) -> Void) {
    guard let node else { return }
    postorder(node.left, visit)
    postorder(node.right, visit)
    visit(node.value)
}`,
    levelorder: `func levelOrder(_ root: TreeNode?, _ visit: (Int) -> Void) {
    var queue = [root].compactMap { $0 }
    var head = 0
    while head < queue.count {
        let node = queue[head]
        head += 1
        visit(node.value)
        if let left = node.left { queue.append(left) }
        if let right = node.right { queue.append(right) }
    }
}`,
};

export const buildBst = (values) => {
    const tree = { root: null, nodes: {} };
    let nextId = 0;
    values.forEach((value) => {
        if (tree.root === null) {
            tree.nodes[nextId] = { value, left: null, right: null };
            tree.root = nextId;
            nextId += 1;
            return;
        }
        let id = tree.root;
        for (;;) {
            const node = tree.nodes[id];
            if (value === node.value) return;
            const side = value < node.value ? 'left' : 'right';
            if (node[side] === null) {
                tree.nodes[nextId] = { value, left: null, right: null };
                node[side] = nextId;
                nextId += 1;
                return;
            }
            id = node[side];
        }
    });
    return tree;
};

function* bstInsert({ values }) {
    let tree = { root: null, nodes: {} };
    for (let index = 0; index < values.length; index += 1) {
        const value = values[index];
        const path = [];
        let id = tree.root;
        while (id !== null && tree.nodes[id].value !== value) {
            path.push(id);
            const node = tree.nodes[id];
            yield { tree, marks: Object.fromEntries(path.map((step) => [step, 'path'])), line: value < node.value ? 4 : 6, message: `Insert ${value}: ${value} ${value < node.value ? '<' : '>'} ${node.value}, so go ${value < node.value ? 'left' : 'right'}.` };
            id = value < node.value ? node.left : node.right;
        }
        if (id !== null) {
            yield { tree, marks: { [id]: 'out' }, line: 7, message: `${value} is already in the tree: duplicates are ignored.` };
            continue;
        }
        tree = buildBst(values.slice(0, index + 1));
        const newId = Object.keys(tree.nodes).find((key) => tree.nodes[key].value === value);
        yield { tree, marks: { [newId]: 'found' }, line: 2, message: `Found an empty spot: ${value} becomes a new leaf.` };
    }
    yield { tree, marks: {}, line: 8, message: `Done. An inorder walk of this tree gives the values in sorted order.` };
}

function* bstSearch({ values, target }) {
    const tree = buildBst(values);
    let id = tree.root;
    const path = [];
    while (id !== null) {
        const node = tree.nodes[id];
        path.push(id);
        if (node.value === target) {
            yield { tree, marks: { ...Object.fromEntries(path.map((step) => [step, 'path'])), [id]: 'found' }, line: 4, message: `Found ${target} after looking at ${path.length} node${path.length === 1 ? '' : 's'}.` };
            return;
        }
        yield { tree, marks: Object.fromEntries(path.map((step) => [step, 'path'])), line: 5, message: `${target} ${target < node.value ? '<' : '>'} ${node.value}: the whole ${target < node.value ? 'right' : 'left'} subtree can be skipped.` };
        id = target < node.value ? node.left : node.right;
    }
    yield { tree, marks: Object.fromEntries(path.map((step) => [step, 'path'])), line: 7, message: `Fell off the tree: ${target} isn't there. ${path.length} comparison${path.length === 1 ? '' : 's'}, one per level.` };
}

function* bstRemove({ values, target }) {
    const tree = clone(buildBst(values));
    const parentOf = (id) => Object.keys(tree.nodes).find((key) => tree.nodes[key].left === Number(id) || tree.nodes[key].right === Number(id));
    const relink = (parent, child, replacement) => {
        if (parent === undefined) tree.root = replacement;
        else if (tree.nodes[parent].left === Number(child)) tree.nodes[parent].left = replacement;
        else tree.nodes[parent].right = replacement;
        delete tree.nodes[child];
    };
    const id = Object.keys(tree.nodes).find((key) => tree.nodes[key].value === target);
    if (id === undefined) {
        yield { tree: clone(tree), marks: {}, line: 2, message: `${target} isn't in the tree, so nothing changes.` };
        return;
    }
    const node = tree.nodes[id];
    if (node.left === null || node.right === null) {
        const child = node.left ?? node.right;
        const kind = child === null ? 'a leaf' : 'a node with one child';
        yield { tree: clone(tree), marks: { [id]: 'out' }, line: node.left === null ? 8 : 9, message: `${target} is ${kind}: its parent simply links to ${child === null ? 'nil' : 'that child'} instead.` };
        relink(parentOf(id), id, child);
    } else {
        let successor = String(node.right);
        const walk = [successor];
        while (tree.nodes[successor].left !== null) {
            successor = String(tree.nodes[successor].left);
            walk.push(successor);
        }
        const successorValue = tree.nodes[successor].value;
        yield { tree: clone(tree), marks: { [id]: 'out', ...Object.fromEntries(walk.map((step) => [step, 'path'])), [successor]: 'found' }, line: 11, message: `${target} has two children. Its successor is the smallest value in its right subtree: ${successorValue}.` };
        node.value = successorValue;
        yield { tree: clone(tree), marks: { [id]: 'found', [successor]: 'out' }, line: 12, message: `Copy ${successorValue} up into the node. The old ${successorValue} has no left child, so removing it is the easy case.` };
        relink(parentOf(successor), successor, tree.nodes[successor].right);
    }
    yield { tree: clone(tree), marks: {}, line: 15, message: `${target} is gone, and the tree is still a valid BST: an inorder walk is still sorted.` };
}

function* traversal({ values, order }) {
    const tree = buildBst(values);
    const output = [];
    const lines = { inorder: 4, preorder: 3, postorder: 5, levelorder: 7 };
    if (order === 'levelorder') {
        const queue = tree.root === null ? [] : [tree.root];
        for (let head = 0; head < queue.length; head += 1) {
            const id = queue[head];
            output.push(tree.nodes[id].value);
            yield { tree, marks: { ...Object.fromEntries(queue.slice(head + 1).map((step) => [step, 'path'])), [id]: 'found' }, line: lines[order], message: `Visit ${tree.nodes[id].value}. Queue next: ${queue.slice(head + 1).map((step) => tree.nodes[step].value).join(', ') || 'nothing'}.`, output: [...output] };
            const { left, right } = tree.nodes[id];
            if (left !== null) queue.push(left);
            if (right !== null) queue.push(right);
        }
    } else {
        const visited = new Set();
        function* walk(id) {
            if (id === null) return;
            const { left, right, value } = tree.nodes[id];
            const visit = function* visitNode() {
                output.push(value);
                visited.add(id);
                yield { tree, marks: { ...Object.fromEntries([...visited].map((step) => [step, 'path'])), [id]: 'found' }, line: lines[order], message: `Visit ${value}.`, output: [...output] };
            };
            if (order === 'preorder') yield* visit();
            yield* walk(left);
            if (order === 'inorder') yield* visit();
            yield* walk(right);
            if (order === 'postorder') yield* visit();
        }
        yield* walk(tree.root);
    }
    yield { tree, marks: {}, line: lines[order], message: `${order === 'levelorder' ? 'Level order' : `${order[0].toUpperCase()}${order.slice(1)}`}: ${output.join(', ')}.${order === 'inorder' ? ' Sorted, because it’s a BST.' : ''}`, output };
}

const BST_PROGRAMS = {
    insert: { title: 'Building a binary search tree', code: BST_CODE.insert, defaults: { values: [50, 30, 70, 20, 40, 60, 80, 35] }, run: bstInsert },
    search: { title: 'Searching a binary search tree', code: BST_CODE.search, defaults: { values: [50, 30, 70, 20, 40, 60, 80, 35], target: 35 }, run: bstSearch },
    remove: { title: 'Removing a node from a binary search tree', code: BST_CODE.remove, defaults: { values: [50, 30, 70, 20, 40, 60, 80, 65], target: 50 }, run: bstRemove },
    traversal: { title: 'Tree traversal', code: BST_CODE.inorder, defaults: { values: [50, 30, 70, 20, 40, 60, 80], order: 'inorder' }, run: traversal },
};

export const BST_PROGRAM_NAMES = Object.keys(BST_PROGRAMS);

export const bstProgram = (name, input = {}) => {
    const program = BST_PROGRAMS[name];
    if (!program) throw new Error(`Unknown BST program "${name}"`);
    const merged = { ...program.defaults, ...input };
    return { ...program, code: name === 'traversal' ? BST_CODE[merged.order] : program.code, input: merged };
};

export const bstFrames = (name, input = {}) => {
    const { run, input: merged } = bstProgram(name, input);
    return [...run(merged)];
};

// ── AVL trees ──────────────────────────────────────────────────────────────────────────────────

export const AVL_CODE = `func insert(_ value: Int, into node: AVLNode?) -> AVLNode {
    guard let node else { return AVLNode(value) }
    if value < node.value {
        node.left = insert(value, into: node.left)
    } else {
        node.right = insert(value, into: node.right)
    }
    node.updateHeight()
    let balance = node.balance          // height(left) - height(right)
    if balance > 1 && value < node.left!.value { return rotateRight(node) }               // LL
    if balance < -1 && value > node.right!.value { return rotateLeft(node) }              // RR
    if balance > 1 { node.left = rotateLeft(node.left!); return rotateRight(node) }       // LR
    if balance < -1 { node.right = rotateRight(node.right!); return rotateLeft(node) }    // RL
    return node
}`;

export const avlFrames = ({ values = [10, 20, 30, 40, 50, 25] } = {}) => {
    let nodes = {};
    let root = null;
    let nextId = 0;
    const heightIn = (map, id) => (id === null ? 0 : 1 + Math.max(heightIn(map, map[id].left), heightIn(map, map[id].right)));
    const view = (map, top) => ({ root: top, nodes: Object.fromEntries(Object.entries(map).map(([id, node]) => [id, { value: node.value, left: node.left, right: node.right, note: String(heightIn(map, node.left) - heightIn(map, node.right)) }])) });
    const copy = (map) => Object.fromEntries(Object.entries(map).map(([id, node]) => [id, { ...node }]));
    const frames = [{ tree: view(nodes, root), marks: {}, line: 1, message: 'An empty AVL tree. The number by each node is its balance factor: height(left) − height(right). It must stay −1, 0 or 1.' }];

    const rotateRight = (map, id) => {
        const pivot = map[id].left;
        map[id].left = map[pivot].right;
        map[pivot].right = id;
        return pivot;
    };
    const rotateLeft = (map, id) => {
        const pivot = map[id].right;
        map[id].right = map[pivot].left;
        map[pivot].left = id;
        return pivot;
    };
    const balanceIn = (map, id) => heightIn(map, map[id].left) - heightIn(map, map[id].right);
    // Plain BST insert with no rebalancing, to show the tree just before a rotation
    const plainInsert = (map, id, value, newId) => {
        if (id === null) {
            map[newId] = { value, left: null, right: null };
            return newId;
        }
        if (value < map[id].value) map[id].left = plainInsert(map, map[id].left, value, newId);
        else map[id].right = plainInsert(map, map[id].right, value, newId);
        return id;
    };
    const insert = (map, id, value, newId, rotations) => {
        if (id === null) {
            map[newId] = { value, left: null, right: null };
            return newId;
        }
        if (value < map[id].value) map[id].left = insert(map, map[id].left, value, newId, rotations);
        else map[id].right = insert(map, map[id].right, value, newId, rotations);
        const balance = balanceIn(map, id);
        if (balance > 1 && value < map[map[id].left].value) { rotations.push(['LL', id]); return rotateRight(map, id); }
        if (balance < -1 && value > map[map[id].right].value) { rotations.push(['RR', id]); return rotateLeft(map, id); }
        if (balance > 1) { rotations.push(['LR', id]); map[id].left = rotateLeft(map, map[id].left); return rotateRight(map, id); }
        if (balance < -1) { rotations.push(['RL', id]); map[id].right = rotateRight(map, map[id].right); return rotateLeft(map, id); }
        return id;
    };
    const explain = { LL: 'left-left case: one right rotation', RR: 'right-right case: one left rotation', LR: 'left-right case: rotate the child left, then this node right', RL: 'right-left case: rotate the child right, then this node left' };

    values.forEach((value) => {
        const newId = nextId;
        nextId += 1;
        const unbalanced = copy(nodes);
        const plainRoot = plainInsert(unbalanced, root, value, newId);
        const rotations = [];
        const rebalanced = copy(nodes);
        const newRoot = insert(rebalanced, root, value, newId, rotations);
        if (rotations.length) {
            const [kind, at] = rotations[0];
            frames.push({ tree: view(unbalanced, plainRoot), marks: { [newId]: 'found', [at]: 'out' }, line: 3, message: `Insert ${value}. Now ${unbalanced[at].value} has balance ${balanceIn(unbalanced, at)}: too lopsided. It’s the ${explain[kind]}.` });
            frames.push({ tree: view(rebalanced, newRoot), marks: { [newId]: 'found' }, line: { LL: 10, RR: 11, LR: 12, RL: 13 }[kind], message: `After rotating, every balance factor is back within −1…1.` });
        } else {
            frames.push({ tree: view(rebalanced, newRoot), marks: { [newId]: 'found' }, line: 14, message: `Insert ${value}. Every balance factor is still −1, 0 or 1: no rotation needed.` });
        }
        nodes = rebalanced;
        root = newRoot;
    });
    frames.push({ tree: view(nodes, root), marks: {}, line: 14, message: `${values.length} values, height ${heightIn(nodes, root)}. A plain BST fed the same values could be up to ${values.length} levels tall.` });
    return frames;
};

// ── Binary heaps ───────────────────────────────────────────────────────────────────────────────

export const HEAP_CODE = `mutating func push(_ value: Int) {
    items.append(value)
    var child = items.count - 1
    while child > 0 && items[(child - 1) / 2] > items[child] {
        items.swapAt(child, (child - 1) / 2)
        child = (child - 1) / 2
    }
}

mutating func pop() -> Int? {
    guard !items.isEmpty else { return nil }
    items.swapAt(0, items.count - 1)
    let smallest = items.removeLast()
    var parent = 0
    while true {
        let left = 2 * parent + 1, right = left + 1
        var next = parent
        if left < items.count && items[left] < items[next] { next = left }
        if right < items.count && items[right] < items[next] { next = right }
        if next == parent { break }
        items.swapAt(parent, next)
        parent = next
    }
    return smallest
}`;

// operations: numbers push, "pop" pops
export const heapFrames = ({ operations = [5, 3, 8, 1, 9, 2, 'pop', 'pop'] } = {}) => {
    const items = [];
    const frames = [{ items: [], marks: {}, line: 1, message: 'An empty min-heap stored in an array: the children of index i live at 2i + 1 and 2i + 2.' }];
    const push = (marks, line, message) => frames.push({ items: [...items], marks, line, message });
    operations.forEach((operation) => {
        if (operation === 'pop') {
            if (!items.length) {
                push({}, 11, 'pop() on an empty heap returns nil.');
                return;
            }
            const smallest = items[0];
            [items[0], items[items.length - 1]] = [items[items.length - 1], items[0]];
            push({ 0: 'swap', [items.length - 1]: 'out' }, 12, `pop(): the root, ${smallest}, is the smallest. Swap it with the last item…`);
            items.pop();
            push({ 0: 'swap' }, 13, `…remove it, and sift the new root down.`);
            let parent = 0;
            for (;;) {
                const left = 2 * parent + 1;
                const right = left + 1;
                let next = parent;
                if (left < items.length && items[left] < items[next]) next = left;
                if (right < items.length && items[right] < items[next]) next = right;
                if (next === parent) break;
                [items[parent], items[next]] = [items[next], items[parent]];
                push({ [parent]: 'swap', [next]: 'swap' }, 21, `${items[parent]} is the smaller child, so swap it up. Continue from index ${next}.`);
                parent = next;
            }
            push({}, 23, `The heap is valid again. pop() returned ${smallest}.`);
        } else {
            items.push(operation);
            let child = items.length - 1;
            push({ [child]: 'found' }, 2, `push(${operation}): add it at the end, the next free spot in the bottom row.`);
            while (child > 0 && items[Math.floor((child - 1) / 2)] > items[child]) {
                const parent = Math.floor((child - 1) / 2);
                [items[child], items[parent]] = [items[parent], items[child]];
                push({ [child]: 'swap', [parent]: 'swap' }, 5, `${items[parent]} is smaller than its parent: swap them. It sifts up.`);
                child = parent;
            }
            push({}, 7, `${operation} has settled. Every parent is ≤ its children.`);
        }
    });
    return frames;
};

export const heapAsTree = (items) => ({
    root: items.length ? 0 : null,
    nodes: Object.fromEntries(items.map((value, index) => [index, { value, left: 2 * index + 1 < items.length ? 2 * index + 1 : null, right: 2 * index + 2 < items.length ? 2 * index + 2 : null }])),
});

// ── Tries ──────────────────────────────────────────────────────────────────────────────────────

export const TRIE_CODE = `func insert(_ word: String) {
    var node = root
    for character in word {
        if node.children[character] == nil {
            node.children[character] = TrieNode()
        }
        node = node.children[character]!
    }
    node.isWord = true
}

func hasPrefix(_ prefix: String) -> Bool {
    var node = root
    for character in prefix {
        guard let next = node.children[character] else { return false }
        node = next
    }
    return true
}`;

export const trieFrames = ({ words = ['car', 'cat', 'cart', 'dog'], prefix = 'ca' } = {}) => {
    const nodes = { 0: { value: '·', children: {}, isWord: false } };
    let nextId = 1;
    const frames = [];
    const snapshot = (marks, line, message) => frames.push({ nodes: JSON.parse(JSON.stringify(nodes)), marks, line, message });
    snapshot({}, 1, 'An empty trie: just the root. Each edge below a node is one character.');
    words.forEach((word) => {
        let id = 0;
        const path = [0];
        let created = 0;
        for (const character of word) {
            if (nodes[id].children[character] === undefined) {
                nodes[nextId] = { value: character, children: {}, isWord: false };
                nodes[id].children[character] = nextId;
                nextId += 1;
                created += 1;
            }
            id = nodes[id].children[character];
            path.push(id);
        }
        nodes[id].isWord = true;
        snapshot(Object.fromEntries(path.map((step) => [step, 'path'])), 9, `Insert "${word}": ${created ? `${created} new node${created === 1 ? '' : 's'}` : 'every node already existed'}${word.length - created > 0 && created ? `, sharing ${word.length - created} with earlier words` : ''}. The last node is marked as the end of a word.`);
    });
    let id = 0;
    const path = [0];
    for (const character of prefix) {
        const next = nodes[id].children[character];
        if (next === undefined) {
            snapshot(Object.fromEntries(path.map((step) => [step, 'path'])), 15, `No "${character}" edge here: no word starts with "${prefix}".`);
            return frames;
        }
        id = next;
        path.push(id);
        snapshot(Object.fromEntries(path.map((step) => [step, 'path'])), 16, `Follow "${character}".`);
    }
    const found = [];
    const collect = (nodeId, sofar) => {
        if (nodes[nodeId].isWord) found.push(sofar);
        Object.entries(nodes[nodeId].children).sort(([a], [b]) => a.localeCompare(b)).forEach(([character, child]) => collect(child, sofar + character));
    };
    collect(id, prefix);
    snapshot({ ...Object.fromEntries(path.map((step) => [step, 'path'])), [id]: 'found' }, 18, `"${prefix}" is a prefix. Everything below this node completes it: ${found.join(', ')}. That's autocomplete, in O(length of the prefix) to get here.`);
    return frames;
};
