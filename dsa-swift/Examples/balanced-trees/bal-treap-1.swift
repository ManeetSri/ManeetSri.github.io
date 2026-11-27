// Generated from src/dsa/content/lessons/balanced-trees/bal-treap.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// A seeded generator (SplitMix64): random-looking numbers, but the same ones every run
struct SeededGenerator: RandomNumberGenerator {
    var state: UInt64
    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

final class TreapNode {
    let key: Int
    let priority: UInt64
    var left: TreapNode?
    var right: TreapNode?

    init(_ key: Int, priority: UInt64) {
        self.key = key
        self.priority = priority
    }
}

// Splits into (keys < key, keys ≥ key)
func split(_ node: TreapNode?, at key: Int) -> (TreapNode?, TreapNode?) {
    guard let node else { return (nil, nil) }
    if node.key < key {
        let (smaller, larger) = split(node.right, at: key)
        node.right = smaller             // node and its left subtree are all < key
        return (node, larger)
    } else {
        let (smaller, larger) = split(node.left, at: key)
        node.left = larger               // node and its right subtree are all ≥ key
        return (smaller, node)
    }
}

// Joins two treaps; every key in a must be below every key in b
func merge(_ a: TreapNode?, _ b: TreapNode?) -> TreapNode? {
    guard let a else { return b }
    guard let b else { return a }
    if a.priority > b.priority {         // a's root stays on top
        a.right = merge(a.right, b)
        return a
    } else {                             // b's root stays on top
        b.left = merge(a, b.left)
        return b
    }
}

func contains(_ key: Int, in root: TreapNode?) -> Bool {
    var current = root
    while let node = current {
        if key == node.key { return true }
        current = key < node.key ? node.left : node.right
    }
    return false
}

func insert(_ key: Int, into root: TreapNode?, using generator: inout SeededGenerator) -> TreapNode? {
    if contains(key, in: root) { return root }
    let (smaller, larger) = split(root, at: key)
    let node = TreapNode(key, priority: generator.next())
    return merge(merge(smaller, node), larger)
}

func remove(_ key: Int, from root: TreapNode?) -> TreapNode? {
    let (smaller, rest) = split(root, at: key)
    let (_, larger) = split(rest, at: key + 1)         // drop the node holding key, if any
    return merge(smaller, larger)
}

func inorder(_ node: TreapNode?) -> [Int] {
    guard let node else { return [] }
    return inorder(node.left) + [node.key] + inorder(node.right)
}

func height(_ node: TreapNode?) -> Int {
    guard let node else { return 0 }
    return 1 + max(height(node.left), height(node.right))
}

var generator = SeededGenerator(state: 42)
var small: TreapNode? = nil
for key in [5, 2, 8, 1, 9, 3, 7, 4, 6, 10] {
    small = insert(key, into: small, using: &generator)
}
let (low, high) = split(small, at: 6)
print("split at 6:", inorder(low), inorder(high))
small = remove(4, from: merge(low, high))
print("merged, then 4 removed:", inorder(small))

var big: TreapNode? = nil
for key in 1...10_000 {
    big = insert(key, into: big, using: &generator)
}
print("10,000 sorted inserts: height \(height(big))")
