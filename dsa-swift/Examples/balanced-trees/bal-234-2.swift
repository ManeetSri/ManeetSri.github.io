// Generated from src/dsa/content/lessons/balanced-trees/bal-234.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// A left-leaning red-black tree: a 2-3 tree in binary form, where a red link joins
// the two keys of a 3-node and always leans left
final class LLRBNode {
    let key: Int
    var left: LLRBNode?
    var right: LLRBNode?
    var isRed = true                     // the link from the parent to this node is red

    init(_ key: Int) { self.key = key }
}

func isRed(_ node: LLRBNode?) -> Bool { node?.isRed ?? false }

func rotateLeft(_ h: LLRBNode) -> LLRBNode {
    let x = h.right!
    h.right = x.left
    x.left = h
    x.isRed = h.isRed
    h.isRed = true
    return x
}

func rotateRight(_ h: LLRBNode) -> LLRBNode {
    let x = h.left!
    h.left = x.right
    x.right = h
    x.isRed = h.isRed
    h.isRed = true
    return x
}

func flipColours(_ h: LLRBNode) {        // split a temporary 4-node: its middle key moves up
    h.isRed = true
    h.left!.isRed = false
    h.right!.isRed = false
}

func insert(_ key: Int, into h: LLRBNode?) -> LLRBNode {
    guard let h else { return LLRBNode(key) }
    if key < h.key {
        h.left = insert(key, into: h.left)
    } else if key > h.key {
        h.right = insert(key, into: h.right)
    }
    var node = h
    if isRed(node.right) && !isRed(node.left) { node = rotateLeft(node) }        // lean left
    if isRed(node.left) && isRed(node.left?.left) { node = rotateRight(node) }   // two reds in a row
    if isRed(node.left) && isRed(node.right) { flipColours(node) }               // a 4-node: split it
    return node
}

func height(_ node: LLRBNode?) -> Int {
    guard let node else { return 0 }
    return 1 + max(height(node.left), height(node.right))
}

// Black links from here down to a nil, if no red link leans right, no two reds are in a row and
// every path has the same number of black links; nil otherwise
func blackHeight(_ node: LLRBNode?) -> Int? {
    guard let node else { return 0 }
    if isRed(node.right) || (node.isRed && isRed(node.left)) { return nil }
    guard let left = blackHeight(node.left), let right = blackHeight(node.right), left == right else { return nil }
    return left + (node.isRed ? 0 : 1)
}

var root: LLRBNode? = nil
for key in 1...1_000 {
    root = insert(key, into: root)
    root!.isRed = false                  // the root is always black
}
print("1,000 sorted inserts: height \(height(root)), black-height \(blackHeight(root) ?? -1)")

var scrambled: LLRBNode? = nil
for i in 0..<1_000 {
    scrambled = insert((i * 7_919) % 1_000, into: scrambled)
    scrambled!.isRed = false
}
print("1,000 scrambled inserts: height \(height(scrambled)), black-height \(blackHeight(scrambled) ?? -1)")
