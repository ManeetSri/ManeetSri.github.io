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

/// A tree of up to `count` nodes in a random shape, with values from `values`, at most `maxLevels`
/// levels tall: a new node that would go deeper is dropped.
private func randomTree(_ count: Int, values: ClosedRange<Int>, maxLevels: Int = .max, generator: inout SeededGenerator) -> TreeNode? {
    guard count > 0 else { return nil }
    let root = TreeNode(Int.random(in: values, using: &generator))
    for _ in 1..<count {
        let value = Int.random(in: values, using: &generator)
        var node = root
        var level = 1
        while level < maxLevels {
            level += 1
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

/// Good nodes counted with an explicit stack of (node, largest value above it).
private func referenceGoodCount(_ root: TreeNode?) -> Int {
    var count = 0
    var pending: [(TreeNode, Int)] = root.map { [($0, Int.min)] } ?? []
    while let (node, highest) = pending.popLast() {
        if node.value >= highest { count += 1 }
        let next = max(highest, node.value)
        if let left = node.left { pending.append((left, next)) }
        if let right = node.right { pending.append((right, next)) }
    }
    return count
}

/// Path numbers by listing every root-to-leaf path's digits and reading each as a number.
private func referenceNumberSum(_ root: TreeNode?) -> Int {
    var total = 0
    var pending: [(TreeNode, [Int])] = root.map { [($0, [$0.value])] } ?? []
    while let (node, digits) = pending.popLast() {
        if node.left == nil && node.right == nil {
            total += digits.reduce(0) { $0 * 10 + $1 }
        }
        if let left = node.left { pending.append((left, digits + [left.value])) }
        if let right = node.right { pending.append((right, digits + [right.value])) }
    }
    return total
}

@Suite struct GoodNodesAndNumbersTests {
    // MARK: goodNodeCount

    @Test("Good nodes in the examples", arguments: [
        ([5, 3, 8, 6, 2, 7, 9], 4),
        ([2, 2, 1, 2], 3),
        ([-1, -5, 0], 2),
        ([4], 1),
        ([9, 8, 7, 6, 5, 4, 3], 1),
        ([1, nil, 2, nil, 3, nil, 4], 4),
    ] as [([Int?], Int)])
    func goodExamples(levelOrder: [Int?], expected: Int) {
        #expect(GoodNodesAndNumbers.goodNodeCount(TreeNode.make(levelOrder)) == expected)
    }

    @Test("The empty tree has no good nodes")
    func goodEmpty() {
        #expect(GoodNodesAndNumbers.goodNodeCount(nil) == 0)
    }

    @Test("A node is compared with its own ancestors, not with nodes in other branches")
    func ancestorsOnly() {
        // The 6 under 3 is good (nothing above it is larger), even though the 8 elsewhere is larger
        let tree = TreeNode.make([5, 3, 8, 6, nil, 7])
        #expect(GoodNodesAndNumbers.goodNodeCount(tree) == 3)
    }

    @Test("Matches a careful count on 300 random trees")
    func goodRandom() {
        var generator = SeededGenerator(state: 50)
        var firstMismatch: String? = nil
        for round in 0..<300 {
            let tree = randomTree(round % 50, values: -10...10, generator: &generator)
            if GoodNodesAndNumbers.goodNodeCount(tree) != referenceGoodCount(tree) {
                firstMismatch = firstMismatch ?? (tree?.description ?? "[]")
            }
        }
        #expect(firstMismatch == nil, "the first tree with a wrong answer")
    }

    @Test("Large trees: 131,071 nodes increasing, decreasing and mixed, and 150,000 random")
    func goodLarge() {
        let increasing = TreeNode.make(Array(1...131_071))
        #expect(GoodNodesAndNumbers.goodNodeCount(increasing) == 131_071)
        let decreasing = TreeNode.make(Array((1...131_071).reversed()))
        #expect(GoodNodesAndNumbers.goodNodeCount(decreasing) == 1)
        let mixed = TreeNode.make((0..<131_071).map { ($0 * 7_919) % 1_000 })
        #expect(GoodNodesAndNumbers.goodNodeCount(mixed) == referenceGoodCount(mixed))
        var generator = SeededGenerator(state: 51)
        let tree = randomTree(150_000, values: Int.min...Int.max, generator: &generator)
        #expect(GoodNodesAndNumbers.goodNodeCount(tree) == referenceGoodCount(tree))
    }

    // MARK: pathNumberSum

    @Test("Path numbers in the examples", arguments: [
        ([4, 0, 7, 2, 9], 858),
        ([0, 1], 1),
        ([7], 7),
        ([1, 0, nil, 0, nil, 5], 1_005),
        ([9, 9, 9], 198),
        ([3, nil, 0, 0, 0], 600),
    ] as [([Int?], Int)])
    func numberExamples(levelOrder: [Int?], expected: Int) {
        #expect(GoodNodesAndNumbers.pathNumberSum(TreeNode.make(levelOrder)) == expected)
    }

    @Test("The empty tree sums to 0")
    func numbersEmpty() {
        #expect(GoodNodesAndNumbers.pathNumberSum(nil) == 0)
    }

    @Test("Matches a careful sum on 300 random trees")
    func numbersRandom() {
        var generator = SeededGenerator(state: 52)
        var firstMismatch: String? = nil
        for round in 0..<300 {
            let tree = randomTree(round % 50, values: 0...9, maxLevels: 12, generator: &generator)
            if GoodNodesAndNumbers.pathNumberSum(tree) != referenceNumberSum(tree) {
                firstMismatch = firstMismatch ?? (tree?.description ?? "[]")
            }
        }
        #expect(firstMismatch == nil, "the first tree with a wrong answer")
    }

    @Test("The largest trees allowed: 12 levels, perfect and random")
    func numbersLarge() {
        let perfect = TreeNode.make((0..<4_095).map { $0 % 10 })
        #expect(GoodNodesAndNumbers.pathNumberSum(perfect) == referenceNumberSum(perfect))
        let nines = TreeNode.make(Array(repeating: 9, count: 4_095))
        #expect(GoodNodesAndNumbers.pathNumberSum(nines) == 2_048 * 999_999_999_999)
        var generator = SeededGenerator(state: 53)
        let tree = randomTree(4_000, values: 0...9, maxLevels: 12, generator: &generator)
        #expect(GoodNodesAndNumbers.pathNumberSum(tree) == referenceNumberSum(tree))
    }
}
