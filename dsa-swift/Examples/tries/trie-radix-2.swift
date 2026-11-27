// Generated from src/dsa/content/lessons/tries/trie-radix.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class RadixNode {
    var label: String                            // the characters on the edge into this node
    var children: [Character: RadixNode] = [:]   // keyed by the first character of each child's label
    var isWord = false

    init(_ label: String) {
        self.label = label
    }
}

func sharedLength(_ a: Substring, _ b: Substring) -> Int {
    var length = 0
    for (x, y) in zip(a, b) {
        if x != y { break }
        length += 1
    }
    return length
}

func insert(_ word: String, into root: RadixNode) {
    var node = root
    var rest = Substring(word)
    while let first = rest.first {
        guard let child = node.children[first] else {
            let leaf = RadixNode(String(rest))   // nothing shares this start: one edge for all of it
            leaf.isWord = true
            node.children[first] = leaf
            return
        }
        let shared = sharedLength(child.label[...], rest)
        if shared < child.label.count {
            // The edge only partly matches: split it, with a new node for the shared part
            let middle = RadixNode(String(child.label.prefix(shared)))
            child.label = String(child.label.dropFirst(shared))
            middle.children[child.label.first!] = child
            node.children[first] = middle
            node = middle
        } else {
            node = child                         // the whole edge matches: go down it
        }
        rest = rest.dropFirst(shared)
    }
    node.isWord = true
}

func contains(_ word: String, in root: RadixNode) -> Bool {
    var node = root
    var rest = Substring(word)
    while let first = rest.first {
        guard let child = node.children[first], rest.hasPrefix(child.label) else { return false }
        rest = rest.dropFirst(child.label.count)
        node = child
    }
    return node.isWord
}

func show(_ node: RadixNode, depth: Int) {
    for key in node.children.keys.sorted() {
        let child = node.children[key]!
        print(String(repeating: "  ", count: depth) + child.label + (child.isWord ? "  (word)" : ""))
        show(child, depth: depth + 1)
    }
}

let root = RadixNode("")
for word in ["in", "into", "integer", "integral", "internal", "internet", "interval", "interview"] {
    insert(word, into: root)
}
show(root, depth: 0)
print(contains("internet", in: root), contains("inter", in: root), contains("integers", in: root))
