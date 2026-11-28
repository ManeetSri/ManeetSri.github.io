// Generated from src/dsa/content/lessons/balanced-trees/bal-why-rotations.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class Node {
    let value: Int
    var left: Node?
    var right: Node?
    init(_ value: Int, _ left: Node? = nil, _ right: Node? = nil) {
        self.value = value
        self.left = left
        self.right = right
    }
}

// Lifts y's left child x above y, and returns x: the new root of this subtree
func rotateRight(_ y: Node) -> Node {
    let x = y.left!
    y.left = x.right        // B moves across from x to y
    x.right = y             // y goes down to x's right
    return x
}

// The mirror image: lifts x's right child y above x, and returns y
func rotateLeft(_ x: Node) -> Node {
    let y = x.right!
    x.right = y.left
    y.left = x
    return y
}

func inorder(_ node: Node?) -> [Int] {
    guard let node else { return [] }
    return inorder(node.left) + [node.value] + inorder(node.right)
}

// The values level by level, top first
func levels(_ root: Node) -> [[Int]] {
    var result: [[Int]] = []
    var level = [root]
    while !level.isEmpty {
        result.append(level.map { $0.value })
        level = level.flatMap { [$0.left, $0.right].compactMap { $0 } }
    }
    return result
}

// y = 40 with left child x = 20. A = 10, B = 30 and C = 50.
let tree = Node(40, Node(20, Node(10), Node(30)), Node(50))
print("before:", levels(tree), inorder(tree))
let rotated = rotateRight(tree)
print("right: ", levels(rotated), inorder(rotated))
let back = rotateLeft(rotated)
print("left:  ", levels(back), inorder(back))
