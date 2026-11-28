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

/// A tree of `count` nodes in a random shape: each new node walks down from the root, turning left or
/// right at random, until it finds a free place.
private func randomTree(_ count: Int, seed: UInt64) -> TreeNode? {
    guard count > 0 else { return nil }
    var generator = SeededGenerator(state: seed)
    let root = TreeNode(0)
    for value in 1..<count {
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

/// The diameter worked out another way, without recursion: visit the nodes in reverse level order, so
/// children come before their parents, and keep every subtree's height in a dictionary.
private func referenceDiameter(_ root: TreeNode?) -> Int {
    guard let root else { return 0 }
    var order = [root]
    var head = 0
    while head < order.count {
        let node = order[head]
        head += 1
        if let left = node.left { order.append(left) }
        if let right = node.right { order.append(right) }
    }
    var height: [ObjectIdentifier: Int] = [:]
    var best = 0
    for node in order.reversed() {
        let left = node.left.map { height[ObjectIdentifier($0)]! } ?? 0
        let right = node.right.map { height[ObjectIdentifier($0)]! } ?? 0
        best = max(best, left + right)
        height[ObjectIdentifier(node)] = 1 + max(left, right)
    }
    return best
}

/// A chain of `count` new nodes going down to the left (or to the right), and its top node.
private func chain(_ count: Int, leftward: Bool) -> TreeNode? {
    var top: TreeNode? = nil
    for value in stride(from: count, to: 0, by: -1) {
        top = leftward ? TreeNode(value, left: top) : TreeNode(value, right: top)
    }
    return top
}

@Suite struct LongestTreePathTests {
    @Test("The examples", arguments: [
        ([1, 2, 3, 4, 5], 3),
        ([1, 2, nil, 3, 4, 5, nil, nil, 6, 7, nil, nil, 8], 6),
        ([4, 2], 1),
        ([9], 0),
        ([1, nil, 2, nil, 3, nil, 4], 3),
    ] as [([Int?], Int)])
    func examples(levelOrder: [Int?], expected: Int) {
        #expect(LongestTreePath.diameter(of: TreeNode.make(levelOrder)) == expected)
    }

    @Test("The empty tree has diameter 0")
    func empty() {
        #expect(LongestTreePath.diameter(of: nil) == 0)
    }

    @Test("The longest path can miss the root entirely")
    func missesTheRoot() {
        // The root has a short right side; the long path bends at its left child
        let tree = TreeNode.make([1, 2, 3, 4, 5, nil, nil, 6, nil, nil, 7, 8, nil, nil, 9])
        #expect(LongestTreePath.diameter(of: tree) == 6)
    }

    @Test("Matches a slow, careful count on 300 random trees")
    func randomTrees() {
        var firstMismatch: String? = nil
        for seed in 1...300 {
            let tree = randomTree(seed % 60 + 1, seed: UInt64(seed))
            if LongestTreePath.diameter(of: tree) != referenceDiameter(tree) {
                firstMismatch = firstMismatch ?? tree?.description
            }
        }
        #expect(firstMismatch == nil, "the first tree with a wrong answer")
    }

    @Test("A perfect tree of 131,071 nodes, 17 levels")
    func perfect() {
        let tree = TreeNode.make(Array(1...131_071))
        #expect(LongestTreePath.diameter(of: tree) == 32)
    }

    @Test("A random tree of 150,000 nodes")
    func largeRandom() {
        let tree = randomTree(150_000, seed: 2024)
        #expect(LongestTreePath.diameter(of: tree) == referenceDiameter(tree))
    }

    @Test("Two long chains hanging from the root: 400 on the left, 300 on the right")
    func chains() {
        let root = TreeNode(0, left: chain(400, leftward: true), right: chain(300, leftward: false))
        #expect(LongestTreePath.diameter(of: root) == 700)
    }
}
