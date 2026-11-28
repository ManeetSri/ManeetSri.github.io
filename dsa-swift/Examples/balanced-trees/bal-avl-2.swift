// Generated from src/dsa/content/lessons/balanced-trees/bal-avl.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class AVLNode {
    var value: Int
    var left: AVLNode?
    var right: AVLNode?
    var height = 1                       // a new node is a leaf: one level

    init(_ value: Int) { self.value = value }
}

func height(_ node: AVLNode?) -> Int {
    node?.height ?? 0                    // the empty tree has height 0
}

func balance(_ node: AVLNode) -> Int {
    height(node.left) - height(node.right)
}

func updateHeight(_ node: AVLNode) {
    node.height = 1 + max(height(node.left), height(node.right))
}

func rotateRight(_ y: AVLNode) -> AVLNode {
    let x = y.left!
    y.left = x.right
    x.right = y
    updateHeight(y)                      // y is now below x, so it goes first
    updateHeight(x)
    return x
}

func rotateLeft(_ x: AVLNode) -> AVLNode {
    let y = x.right!
    x.right = y.left
    y.left = x
    updateHeight(x)
    updateHeight(y)
    return y
}

var rotations: [String] = []             // a log, so we can see what happened

func rebalance(_ node: AVLNode) -> AVLNode {
    updateHeight(node)
    let factor = balance(node)
    if factor > 1 {                                      // left side too tall
        if balance(node.left!) < 0 {                     // …and the left child leans right
            rotations.append("LR at \(node.value)")
            node.left = rotateLeft(node.left!)
        } else {
            rotations.append("LL at \(node.value)")
        }
        return rotateRight(node)
    }
    if factor < -1 {                                     // right side too tall
        if balance(node.right!) > 0 {                    // …and the right child leans left
            rotations.append("RL at \(node.value)")
            node.right = rotateRight(node.right!)
        } else {
            rotations.append("RR at \(node.value)")
        }
        return rotateLeft(node)
    }
    return node
}

func insert(_ value: Int, into node: AVLNode?) -> AVLNode {
    guard let node else { return AVLNode(value) }
    if value < node.value {
        node.left = insert(value, into: node.left)
    } else if value > node.value {
        node.right = insert(value, into: node.right)
    } else {
        return node                                      // already there: a set stores it once
    }
    return rebalance(node)                               // on the way back up
}

func levels(_ root: AVLNode?) -> [[Int]] {
    var result: [[Int]] = []
    var level = root.map { [$0] } ?? []
    while !level.isEmpty {
        result.append(level.map { $0.value })
        level = level.flatMap { [$0.left, $0.right].compactMap { $0 } }
    }
    return result
}

var root: AVLNode? = nil
for value in [10, 20, 30, 40, 50, 25] {
    rotations.removeAll()
    root = insert(value, into: root)
    let note = rotations.first.map { "   (\($0))" } ?? ""
    print("insert \(value): \(levels(root))" + note)
}
