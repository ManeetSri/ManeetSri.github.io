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

/// A tree of `count` nodes in a random shape, with values from `values`.
private func randomTree(_ count: Int, values: ClosedRange<Int>, generator: inout SeededGenerator) -> TreeNode? {
    guard count > 0 else { return nil }
    let root = TreeNode(Int.random(in: values, using: &generator))
    for _ in 1..<count {
        let value = Int.random(in: values, using: &generator)
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

/// Every node, in level order.
private func nodes(of root: TreeNode?) -> [TreeNode] {
    var order: [TreeNode] = root.map { [$0] } ?? []
    var head = 0
    while head < order.count {
        let node = order[head]
        head += 1
        if let left = node.left { order.append(left) }
        if let right = node.right { order.append(right) }
    }
    return order
}

/// The brute force: treat the tree as a graph, and from every node add up every path that starts
/// there. O(n²), for small trees only.
private func bruteForceBest(_ root: TreeNode?) -> Int? {
    let all = nodes(of: root)
    guard !all.isEmpty else { return nil }
    var parent: [ObjectIdentifier: TreeNode] = [:]
    for node in all {
        for child in [node.left, node.right].compactMap({ $0 }) {
            parent[ObjectIdentifier(child)] = node
        }
    }
    var best = Int.min
    for start in all {
        var pending: [(node: TreeNode, from: TreeNode?, sum: Int)] = [(start, nil, start.value)]
        while let (node, from, sum) = pending.popLast() {
            best = max(best, sum)
            for neighbour in [node.left, node.right, parent[ObjectIdentifier(node)]] {
                if let neighbour, neighbour !== from {
                    pending.append((neighbour, node, sum + neighbour.value))
                }
            }
        }
    }
    return best
}

/// The same answer by the one-pass method, but with a loop instead of recursion: gains are worked out
/// in reverse level order, so children come before their parents.
private func referenceBest(_ root: TreeNode?) -> Int? {
    let all = nodes(of: root)
    guard !all.isEmpty else { return nil }
    var gain: [ObjectIdentifier: Int] = [:]
    var best = Int.min
    for node in all.reversed() {
        let left = max(0, node.left.map { gain[ObjectIdentifier($0)]! } ?? 0)
        let right = max(0, node.right.map { gain[ObjectIdentifier($0)]! } ?? 0)
        best = max(best, node.value + left + right)
        gain[ObjectIdentifier(node)] = node.value + max(left, right)
    }
    return best
}

@Suite struct RichestTreePathTests {
    @Test("The examples", arguments: [
        ([-8, 4, 12, nil, nil, 6, 9], 27),
        ([5, -6, 4, 8, 3, nil, -9, nil, nil, nil, nil, 7, 2], 11),
        ([1, 2, 3], 6),
        ([2, -1], 2),
        ([-3], -3),
        ([-5, -2, -7], -2),
    ] as [([Int?], Int)])
    func examples(levelOrder: [Int?], expected: Int) {
        #expect(RichestTreePath.maximumPathSum(TreeNode.make(levelOrder)) == expected)
    }

    @Test("The empty tree has no paths")
    func empty() {
        #expect(RichestTreePath.maximumPathSum(nil) == nil)
    }

    @Test("A path can't fork: it bends at most once")
    func noForks() {
        // Taking all four 10s would need a fork at the root. The best real path uses three of them.
        let tree = TreeNode.make([1, 10, 10, 10, 10])
        #expect(RichestTreePath.maximumPathSum(tree) == 31)
    }

    @Test("All negative values: the best path is the single largest value")
    func allNegative() {
        let tree = TreeNode.make([-10, -20, -3, -40, -5, -60, -1])
        #expect(RichestTreePath.maximumPathSum(tree) == -1)
    }

    @Test("Matches the brute force on 400 random trees")
    func randomTrees() {
        var generator = SeededGenerator(state: 8)
        var firstMismatch: String? = nil
        for round in 0..<400 {
            let low = round % 3 == 0 ? -20 : -10
            let tree = randomTree(round % 40 + 1, values: low...10, generator: &generator)
            if RichestTreePath.maximumPathSum(tree) != bruteForceBest(tree) {
                firstMismatch = firstMismatch ?? (tree?.description ?? "[]")
            }
        }
        #expect(firstMismatch == nil, "the first tree with a wrong answer")
    }

    @Test("Perfect trees of 131,071 nodes")
    func largePerfect() {
        let ones = TreeNode.make(Array(repeating: 1, count: 131_071))
        #expect(RichestTreePath.maximumPathSum(ones) == 33)
        let minusOnes = TreeNode.make(Array(repeating: -1, count: 131_071))
        #expect(RichestTreePath.maximumPathSum(minusOnes) == -1)
        let mixed = TreeNode.make((0..<131_071).map { ($0 * 7_919) % 201 - 100 })
        #expect(RichestTreePath.maximumPathSum(mixed) == referenceBest(mixed))
    }

    @Test("A random tree of 150,000 nodes")
    func largeRandom() {
        var generator = SeededGenerator(state: 31)
        let tree = randomTree(150_000, values: -1_000...1_000, generator: &generator)
        #expect(RichestTreePath.maximumPathSum(tree) == referenceBest(tree))
    }
}
