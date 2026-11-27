// Generated from src/dsa/content/lessons/balanced-trees/bal-avl.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class AVLNode {
    var value: Int                       // var: a removal can copy a successor's value in
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

var rotations: [String] = []

func rebalance(_ node: AVLNode) -> AVLNode {
    updateHeight(node)
    let factor = balance(node)
    if factor > 1 {
        if balance(node.left!) < 0 {
            rotations.append("LR at \(node.value)")
            node.left = rotateLeft(node.left!)
        } else {
            rotations.append("LL at \(node.value)")
        }
        return rotateRight(node)
    }
    if factor < -1 {
        if balance(node.right!) > 0 {
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
        return node
    }
    return rebalance(node)
}

func remove(_ value: Int, from node: AVLNode?) -> AVLNode? {
    guard let node else { return nil }                   // not in the tree
    if value < node.value {
        node.left = remove(value, from: node.left)
    } else if value > node.value {
        node.right = remove(value, from: node.right)
    } else {
        // Found it. With at most one child, the child takes its place.
        guard let left = node.left else { return node.right }
        guard let right = node.right else { return left }
        // Two children: copy the successor's value here, then remove the successor
        var successor = right
        while let smaller = successor.left {
            successor = smaller
        }
        node.value = successor.value
        node.right = remove(successor.value, from: right)
    }
    return rebalance(node)                               // every node on the way back up
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
for value in [8, 5, 11, 3, 7, 10, 12, 2, 4, 6, 9, 1] {
    root = insert(value, into: root)
}
print("before:", levels(root))
rotations.removeAll()
root = remove(12, from: root)
print("after: ", levels(root))
print("rotations:", rotations)
rotations.removeAll()
root = remove(5, from: root)
print("remove 5:", levels(root), rotations)
