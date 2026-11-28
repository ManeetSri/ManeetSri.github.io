import Testing
import DSAKit
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small random number generator that gives the same numbers every run.
private struct SeededGenerator: RandomNumberGenerator {
    var state: UInt64
    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

/// A tree of `count` nodes in a random shape, holding distinct values in a random order.
private func randomTree(_ count: Int, generator: inout SeededGenerator) -> TreeNode? {
    guard count > 0 else { return nil }
    let values = Array(-count..<count).shuffled(using: &generator)
    let root = TreeNode(values[0])
    for value in values[1..<count] {
        var node = root
        while true {
            if Bool.random(using: &generator) {
                guard let left = node.left else { node.left = TreeNode(value); break }
                node = left
            } else {
                guard let right = node.right else { node.right = TreeNode(value); break }
                node = right
            }
        }
    }
    return root
}

/// Preorder, with an explicit stack.
private func preorder(_ root: TreeNode?) -> [Int] {
    var result: [Int] = []
    var pending: [TreeNode] = root.map { [$0] } ?? []
    while let node = pending.popLast() {
        result.append(node.value)
        if let right = node.right { pending.append(right) }
        if let left = node.left { pending.append(left) }
    }
    return result
}

/// Postorder: a node-right-left preorder, reversed.
private func postorder(_ root: TreeNode?) -> [Int] {
    var result: [Int] = []
    var pending: [TreeNode] = root.map { [$0] } ?? []
    while let node = pending.popLast() {
        result.append(node.value)
        if let left = node.left { pending.append(left) }
        if let right = node.right { pending.append(right) }
    }
    return result.reversed()
}

/// Checks both rebuilds against the original tree, and returns a description of the first failure.
private func failure(rebuilding tree: TreeNode?) -> String? {
    let expected = tree?.levelOrder ?? []
    let inorder = tree?.inorder ?? []
    let shown = expected.count <= 40 ? "\(expected)" : "a tree of \(inorder.count) nodes"
    if (RebuildFromOrders.fromPreorder(preorder(tree), inorder: inorder)?.levelOrder ?? []) != expected {
        return "fromPreorder for \(shown)"
    }
    if (RebuildFromOrders.fromPostorder(postorder(tree), inorder: inorder)?.levelOrder ?? []) != expected {
        return "fromPostorder for \(shown)"
    }
    return nil
}

@Suite struct RebuildFromOrdersTests {
    @Test("The example: preorder and inorder")
    func examplePreorder() {
        let tree = RebuildFromOrders.fromPreorder([1, 2, 4, 5, 3, 6], inorder: [4, 2, 5, 1, 3, 6])
        #expect(tree?.levelOrder == [1, 2, 3, 4, 5, nil, 6])
    }

    @Test("The example: postorder and inorder")
    func examplePostorder() {
        let tree = RebuildFromOrders.fromPostorder([4, 5, 2, 6, 3, 1], inorder: [4, 2, 5, 1, 3, 6])
        #expect(tree?.levelOrder == [1, 2, 3, 4, 5, nil, 6])
    }

    @Test("Shapes that only the inorder can tell apart", arguments: [
        [1, 2], [1, nil, 2], [8, 3, nil, nil, 5], [8, nil, 3, 5], [7], [-1, -2, -3, nil, -4, -5],
    ] as [[Int?]])
    func smallShapes(levelOrder: [Int?]) {
        #expect(failure(rebuilding: TreeNode.make(levelOrder)) == nil)
    }

    @Test("Empty traversals give the empty tree")
    func empty() {
        #expect(RebuildFromOrders.fromPreorder([], inorder: []) == nil)
        #expect(RebuildFromOrders.fromPostorder([], inorder: []) == nil)
    }

    @Test("400 random trees")
    func randomTrees() {
        var generator = SeededGenerator(state: 6)
        var firstFailure: String? = nil
        for round in 0..<400 {
            let tree = randomTree(round % 50 + 1, generator: &generator)
            firstFailure = firstFailure ?? failure(rebuilding: tree)
        }
        #expect(firstFailure == nil)
    }

    @Test("A perfect tree of 131,071 nodes")
    func largePerfect() {
        let tree = TreeNode.make(Array(1...131_071))
        #expect(failure(rebuilding: tree) == nil)
    }

    @Test("A random tree of 150,000 nodes")
    func largeRandom() {
        var generator = SeededGenerator(state: 60)
        let tree = randomTree(150_000, generator: &generator)
        #expect(failure(rebuilding: tree) == nil)
    }

    @Test("Chains 500 nodes deep, to the left, to the right and zigzagging")
    func chains() {
        for shape in 0..<3 {
            var top: TreeNode? = nil
            for value in 0..<500 {
                let goLeft = shape == 0 || (shape == 2 && value % 2 == 0)
                top = goLeft ? TreeNode(value, left: top) : TreeNode(value, right: top)
            }
            #expect(failure(rebuilding: top) == nil)
        }
    }
}
