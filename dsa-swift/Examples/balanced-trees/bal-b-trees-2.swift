// Generated from src/dsa/content/lessons/balanced-trees/bal-b-trees.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// A B-tree where a node holds at most 3 keys, so it has at most 4 children
final class BNode {
    var keys: [Int] = []                // sorted
    var children: [BNode] = []          // empty for a leaf; otherwise keys.count + 1 of them
    var isLeaf: Bool { children.isEmpty }
}

struct BTree {
    static let maxKeys = 3
    var root = BNode()

    mutating func insert(_ key: Int) {
        guard let (median, right) = Self.insert(key, into: root) else { return }
        let newRoot = BNode()           // the root split: the tree grows one level, at the top
        newRoot.keys = [median]
        newRoot.children = [root, right]
        root = newRoot
    }

    // Inserts key below node. If node ends up too full, it splits, returning its median key and
    // its new right half for the parent to take in.
    static func insert(_ key: Int, into node: BNode) -> (median: Int, right: BNode)? {
        var i = 0
        while i < node.keys.count && node.keys[i] < key {
            i += 1                      // now keys[i] is the first key ≥ key, and child i is key's way down
        }
        if i < node.keys.count && node.keys[i] == key { return nil }   // already there
        if node.isLeaf {
            node.keys.insert(key, at: i)
        } else if let (median, right) = insert(key, into: node.children[i]) {
            node.keys.insert(median, at: i)             // the child split: take in its median…
            node.children.insert(right, at: i + 1)      // …and its new right half
        }
        guard node.keys.count > maxKeys else { return nil }
        // Too full: keep the left half, pass the middle key up, move the right half to a new node
        let mid = node.keys.count / 2
        let median = node.keys[mid]
        let right = BNode()
        right.keys = Array(node.keys[(mid + 1)...])
        node.keys.removeSubrange(mid...)
        if !node.isLeaf {
            right.children = Array(node.children[(mid + 1)...])
            node.children.removeSubrange((mid + 1)...)
        }
        return (median, right)
    }

    // How many nodes a search reads, or nil if key isn't there
    func nodesRead(searchingFor key: Int) -> Int? {
        var node = root
        var reads = 1
        while true {
            var i = 0
            while i < node.keys.count && node.keys[i] < key { i += 1 }
            if i < node.keys.count && node.keys[i] == key { return reads }
            if node.isLeaf { return nil }
            node = node.children[i]
            reads += 1
        }
    }

    // Each level's nodes, top first, such as [4] / [2] [6 8] / …
    var levels: String {
        var lines: [String] = []
        var level = [root]
        while !level.isEmpty {
            lines.append(level.map { "[" + $0.keys.map(String.init).joined(separator: " ") + "]" }.joined(separator: " "))
            level = level.flatMap { $0.children }
        }
        return lines.joined(separator: " / ")
    }
}

var tree = BTree()
for key in 1...13 {
    tree.insert(key)
    print("insert \(key): \(tree.levels)")
}
print("a search for 11 reads \(tree.nodesRead(searchingFor: 11) ?? 0) nodes")
