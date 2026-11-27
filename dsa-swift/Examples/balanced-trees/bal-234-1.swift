// Generated from src/dsa/content/lessons/balanced-trees/bal-234.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// A 2-3-4 tree: every node holds 1, 2 or 3 keys, and every leaf is at the same depth
final class Node234 {
    var keys: [Int]
    var children: [Node234]             // empty for a leaf; otherwise keys.count + 1 of them
    init(_ keys: [Int], _ children: [Node234] = []) {
        self.keys = keys
        self.children = children
    }
}

// Splits the full child at children[i] of parent: its middle key moves up into parent
func splitChild(_ parent: Node234, _ i: Int) {
    let full = parent.children[i]
    let left = Node234([full.keys[0]], Array(full.children.prefix(2)))
    let right = Node234([full.keys[2]], Array(full.children.dropFirst(2)))
    parent.keys.insert(full.keys[1], at: i)
    parent.children[i] = left
    parent.children.insert(right, at: i + 1)
}

// Top-down insertion: split every 4-node on the way down, so the leaf always has room
func insert(_ key: Int, into root: Node234?) -> Node234 {
    guard var root else { return Node234([key]) }
    if root.keys.count == 3 {                       // a full root splits: the tree grows at the top
        let newRoot = Node234([], [root])
        splitChild(newRoot, 0)
        root = newRoot
    }
    var node = root
    while true {
        var i = 0
        while i < node.keys.count && node.keys[i] < key { i += 1 }
        if i < node.keys.count && node.keys[i] == key { return root }   // already there
        if node.children.isEmpty {
            node.keys.insert(key, at: i)            // a leaf with room, guaranteed
            return root
        }
        if node.children[i].keys.count == 3 {      // full child: split it before stepping down
            splitChild(node, i)                     // its middle key is now node.keys[i]
            if key == node.keys[i] { return root }
            if key > node.keys[i] { i += 1 }       // carry on into the correct half
        }
        node = node.children[i]
    }
}

// The same tree as a red-black tree: each 2-3-4 node becomes a black node with 0, 1 or 2 red children
final class RBNode {
    let value: Int
    let isRed: Bool
    var left: RBNode?
    var right: RBNode?
    init(_ value: Int, red: Bool, _ left: RBNode?, _ right: RBNode?) {
        self.value = value
        self.isRed = red
        self.left = left
        self.right = right
    }
}

func redBlack(_ node: Node234?) -> RBNode? {
    guard let node else { return nil }
    let kids = node.children.map { redBlack($0) }
    let child = { (i: Int) in i < kids.count ? kids[i] : nil }
    switch node.keys.count {
    case 1:                                         // 2-node: one black node
        return RBNode(node.keys[0], red: false, child(0), child(1))
    case 2:                                         // 3-node: black, with a red left child
        let red = RBNode(node.keys[0], red: true, child(0), child(1))
        return RBNode(node.keys[1], red: false, red, child(2))
    default:                                        // 4-node: black, with two red children
        let left = RBNode(node.keys[0], red: true, child(0), child(1))
        let right = RBNode(node.keys[2], red: true, child(2), child(3))
        return RBNode(node.keys[1], red: false, left, right)
    }
}

// Black nodes from here down to a nil, if properties 4 and 5 hold; nil if they don't
func blackHeight(_ node: RBNode?) -> Int? {
    guard let node else { return 0 }
    if node.isRed && (node.left?.isRed == true || node.right?.isRed == true) { return nil }
    guard let left = blackHeight(node.left), let right = blackHeight(node.right), left == right else { return nil }
    return left + (node.isRed ? 0 : 1)
}

func levels234(_ root: Node234) -> String {
    var lines: [String] = []
    var level = [root]
    while !level.isEmpty {
        lines.append(level.map { "[" + $0.keys.map(String.init).joined(separator: " ") + "]" }.joined(separator: " "))
        level = level.flatMap { $0.children }
    }
    return lines.joined(separator: " / ")
}

func levelsRB(_ root: RBNode?) -> String {
    var lines: [String] = []
    var level = root.map { [$0] } ?? []
    while !level.isEmpty {
        lines.append(level.map { "\($0.value)\($0.isRed ? "R" : "B")" }.joined(separator: " "))
        level = level.flatMap { [$0.left, $0.right].compactMap { $0 } }
    }
    return lines.joined(separator: " / ")
}

var tree: Node234? = nil
for key in [10, 20, 30, 40, 50, 60, 70, 5, 15, 25] {
    tree = insert(key, into: tree)
}
print("2-3-4:    ", levels234(tree!))
let rb = redBlack(tree)
print("red-black:", levelsRB(rb))

var depth = 0                                       // every leaf of a 2-3-4 tree is at this depth
var node = tree
while let current = node {
    depth += 1
    node = current.children.first
}
print("2-3-4 height \(depth), black-height \(blackHeight(rb) ?? -1)")
