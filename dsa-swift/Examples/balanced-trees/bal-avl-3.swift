// Generated from src/dsa/content/lessons/balanced-trees/bal-avl.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class AVLNode {
    var value: Int
    var left: AVLNode?
    var right: AVLNode?
    var height = 1

    init(_ value: Int) { self.value = value }
}

func height(_ node: AVLNode?) -> Int {
    node?.height ?? 0
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
    updateHeight(y)
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

var fixes = 0

func rebalance(_ node: AVLNode) -> AVLNode {
    updateHeight(node)
    let factor = balance(node)
    if factor > 1 {
        fixes += 1
        if balance(node.left!) < 0 { node.left = rotateLeft(node.left!) }
        return rotateRight(node)
    }
    if factor < -1 {
        fixes += 1
        if balance(node.right!) > 0 { node.right = rotateRight(node.right!) }
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
        return node
    }
    return rebalance(node)
}

for n in [1_000, 100_000] {
    var root: AVLNode? = nil
    fixes = 0
    for value in 1...n {
        root = insert(value, into: root)
    }
    print("\(n) sorted inserts: height \(height(root)), \(fixes) fixes")
}
