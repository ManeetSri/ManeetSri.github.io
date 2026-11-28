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

func rotateRight(_ y: Node) -> Node {
    let x = y.left!
    y.left = x.right
    x.right = y
    return x
}

func rotateLeft(_ x: Node) -> Node {
    let y = x.right!
    x.right = y.left
    y.left = x
    return y
}

func levels(_ root: Node) -> [[Int]] {
    var result: [[Int]] = []
    var level = [root]
    while !level.isEmpty {
        result.append(level.map { $0.value })
        level = level.flatMap { [$0.left, $0.right].compactMap { $0 } }
    }
    return result
}

// A straight chain: 30, then 20 on its left, then 10 on the left of that
let straight = Node(30, Node(20, Node(10)))
print("straight:", levels(straight), "→", levels(rotateRight(straight)))

// A bent chain: 30, then 10 on its left, then 20 on the right of 10
let bent = Node(30, Node(10, nil, Node(20)))
print("bent, one rotation: ", levels(rotateRight(bent)))

let bentAgain = Node(30, Node(10, nil, Node(20)))
bentAgain.left = rotateLeft(bentAgain.left!)      // straighten the bend first
print("bent, two rotations:", levels(rotateRight(bentAgain)))
