// Huffman coding: repeatedly merge the two lightest trees. Frames: { forest: [tree snapshot], marks, codes?,
// line, message }, where each tree is { root, nodes: { id: { value, left, right, weight, symbol } } } for TreeDiagram.

export const HUFFMAN_CODE = `final class HuffmanNode {
    let weight: Int
    let symbol: Character?
    let left: HuffmanNode?, right: HuffmanNode?
    init(weight: Int, symbol: Character? = nil, left: HuffmanNode? = nil, right: HuffmanNode? = nil) {
        self.weight = weight; self.symbol = symbol; self.left = left; self.right = right
    }
}

func huffmanCodes(_ frequencies: [(Character, Int)]) -> [Character: String] {
    var forest = frequencies.map { HuffmanNode(weight: $0.1, symbol: $0.0) }
    while forest.count > 1 {
        forest.sort { $0.weight > $1.weight }        // a heap in real code: the two lightest are at the end
        let lightest = forest.removeLast(), next = forest.removeLast()
        forest.append(HuffmanNode(weight: lightest.weight + next.weight, left: lightest, right: next))
    }
    var codes: [Character: String] = [:]
    func walk(_ node: HuffmanNode?, _ code: String) {
        guard let node else { return }
        if let symbol = node.symbol { codes[symbol] = code.isEmpty ? "0" : code; return }
        walk(node.left, code + "0")                  // left adds a 0, right adds a 1
        walk(node.right, code + "1")
    }
    walk(forest.first, "")
    return codes
}`;

export const huffmanFrames = ({ frequencies = { a: 5, b: 9, c: 12, d: 13, e: 16, f: 45 } } = {}) => {
    const entries = Object.entries(frequencies);
    const nodes = {};
    let nextId = 0;
    let order = 0;
    const make = (fields) => {
        const id = String(nextId);
        nextId += 1;
        nodes[id] = { left: null, right: null, order, ...fields };
        order += 1;
        return id;
    };
    let forest = entries.map(([symbol, weight]) => make({ value: `${symbol}:${weight}`, weight, symbol }));
    // Lightest first; ties go to the tree made earlier, so the result is deterministic
    const lightestFirst = (a, b) => nodes[a].weight - nodes[b].weight || nodes[a].order - nodes[b].order;
    const subtree = (root) => {
        const ids = [];
        const visit = (id) => { if (id === null) return; ids.push(id); visit(nodes[id].left); visit(nodes[id].right); };
        visit(root);
        return { root, nodes: Object.fromEntries(ids.map((id) => [id, { ...nodes[id] }])) };
    };
    const frames = [];
    const snapshot = (line, message, marks = {}, codes) => frames.push({ forest: [...forest].sort(lightestFirst).map(subtree), marks, codes, line, message });
    snapshot(12, `Each symbol starts as a one-node tree weighted by how often it appears: ${entries.map(([s, w]) => `${s} ${w}`).join(', ')}.`);
    while (forest.length > 1) {
        forest.sort(lightestFirst);
        const [lightest, next] = forest;
        forest = forest.slice(2);
        const merged = make({ value: String(nodes[lightest].weight + nodes[next].weight), weight: nodes[lightest].weight + nodes[next].weight, left: lightest, right: next });
        forest.push(merged);
        snapshot(16, `Merge the two lightest trees, ${nodes[lightest].weight} and ${nodes[next].weight}, under a new root of ${nodes[merged].weight}. Rare symbols sink deepest, so they get the longest codes.`, { [merged]: 'found', [lightest]: 'swap', [next]: 'swap' });
    }
    const codes = {};
    const walk = (id, code) => {
        if (id === null) return;
        if (nodes[id].symbol !== undefined) { codes[nodes[id].symbol] = code || '0'; return; }
        walk(nodes[id].left, `${code}0`);
        walk(nodes[id].right, `${code}1`);
    };
    walk(forest[0], '');
    const total = entries.reduce((sum, [symbol, weight]) => sum + weight * codes[symbol].length, 0);
    const fixed = Math.max(1, Math.ceil(Math.log2(entries.length)));
    const count = entries.reduce((sum, [, weight]) => sum + weight, 0);
    snapshot(25, `Read each code off the path from the root: left is 0, right is 1. ${total} bits in total, against ${fixed * count} with a fixed ${fixed}-bit code. No code is a prefix of another, so decoding is unambiguous.`, {}, entries.map(([symbol, weight]) => ({ symbol, weight, code: codes[symbol] })));
    return frames;
};
