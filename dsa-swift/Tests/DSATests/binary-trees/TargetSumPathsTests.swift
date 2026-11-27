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

/// Every root-to-leaf path with the target sum, found with an explicit stack of (node, path so far).
/// The right child is pushed first, so leaves come off the stack from left to right.
private func referencePaths(_ root: TreeNode?, _ target: Int) -> [[Int]] {
    var result: [[Int]] = []
    var pending: [(TreeNode, [Int])] = root.map { [($0, [$0.value])] } ?? []
    while let (node, path) = pending.popLast() {
        if node.left == nil && node.right == nil {
            if path.reduce(0, +) == target { result.append(path) }
            continue
        }
        if let right = node.right { pending.append((right, path + [right.value])) }
        if let left = node.left { pending.append((left, path + [left.value])) }
    }
    return result
}

/// Downward paths with the target sum, counted slowly: from every node, add up every path going down.
private func referenceCount(_ root: TreeNode?, _ target: Int) -> Int {
    var count = 0
    var starts: [TreeNode] = root.map { [$0] } ?? []
    while let start = starts.popLast() {
        var pending: [(TreeNode, Int)] = [(start, start.value)]
        while let (node, sum) = pending.popLast() {
            if sum == target { count += 1 }
            if let left = node.left { pending.append((left, sum + left.value)) }
            if let right = node.right { pending.append((right, sum + right.value)) }
        }
        if let left = start.left { starts.append(left) }
        if let right = start.right { starts.append(right) }
    }
    return count
}

@Suite struct TargetSumPathsTests {
    static let example: [Int?] = [6, 3, 9, 4, 1, nil, -2, nil, nil, 5]

    @Test("Root-to-leaf paths in the example", arguments: [
        (13, [[6, 3, 4], [6, 9, -2]]),
        (15, [[6, 3, 1, 5]]),
        (9, []),
        (6, []),
    ] as [(Int, [[Int]])])
    func examplePaths(target: Int, expected: [[Int]]) {
        #expect(TargetSumPaths.rootToLeafPaths(in: TreeNode.make(Self.example), summingTo: target) == expected)
    }

    @Test("Downward paths in the example", arguments: [
        (13, 2), (9, 3), (7, 2), (6, 2), (15, 2), (100, 0), (-2, 1),
    ])
    func exampleCounts(target: Int, expected: Int) {
        #expect(TargetSumPaths.downwardPathCount(in: TreeNode.make(Self.example), summingTo: target) == expected)
    }

    @Test("A path must end at a leaf, but a downward path can stop anywhere")
    func leavesOnly() {
        let tree = TreeNode.make([1, 2])
        #expect(TargetSumPaths.rootToLeafPaths(in: tree, summingTo: 1) == [])
        #expect(TargetSumPaths.rootToLeafPaths(in: tree, summingTo: 3) == [[1, 2]])
        #expect(TargetSumPaths.downwardPathCount(in: tree, summingTo: 1) == 1)
        #expect(TargetSumPaths.downwardPathCount(in: tree, summingTo: 2) == 1)
    }

    @Test("Zeros: every path counts")
    func zeros() {
        let tree = TreeNode.make([0, 0, 0])
        #expect(TargetSumPaths.rootToLeafPaths(in: tree, summingTo: 0) == [[0, 0], [0, 0]])
        #expect(TargetSumPaths.downwardPathCount(in: tree, summingTo: 0) == 5)
    }

    @Test("One node, and the empty tree")
    func tiny() {
        #expect(TargetSumPaths.rootToLeafPaths(in: TreeNode(5), summingTo: 5) == [[5]])
        #expect(TargetSumPaths.downwardPathCount(in: TreeNode(5), summingTo: 5) == 1)
        #expect(TargetSumPaths.rootToLeafPaths(in: nil, summingTo: 0) == [])
        #expect(TargetSumPaths.downwardPathCount(in: nil, summingTo: 0) == 0)
    }

    @Test("A path that goes back out of a branch must forget that branch's sums")
    func backtracking() {
        // The left branch 5 → 3 → 2 leaves running sums 8 and 10 behind. On the right, the running sum
        // at 8 is 10 again: the left branch's 8 and 10 aren't above it, so they mustn't be counted.
        let tree = TreeNode.make([5, 3, -3, 2, nil, nil, 8])
        #expect(TargetSumPaths.downwardPathCount(in: tree, summingTo: 10) == 2)
        #expect(TargetSumPaths.downwardPathCount(in: tree, summingTo: 5) == 3)
        #expect(TargetSumPaths.downwardPathCount(in: tree, summingTo: 2) == 2)
        #expect(TargetSumPaths.downwardPathCount(in: tree, summingTo: 0) == 0)
        #expect(TargetSumPaths.rootToLeafPaths(in: tree, summingTo: 10) == [[5, 3, 2], [5, -3, 8]])
    }

    @Test("Matches slow counts on 300 random trees with negative values")
    func randomTrees() {
        var generator = SeededGenerator(state: 3)
        var firstMismatch: String? = nil
        for round in 0..<300 {
            let tree = randomTree(round % 50, values: -4...4, generator: &generator)
            let target = Int.random(in: -6...6, using: &generator)
            if TargetSumPaths.rootToLeafPaths(in: tree, summingTo: target) != referencePaths(tree, target)
                || TargetSumPaths.downwardPathCount(in: tree, summingTo: target) != referenceCount(tree, target) {
                firstMismatch = firstMismatch ?? "target \(target) in \(tree?.description ?? "[]")"
            }
        }
        #expect(firstMismatch == nil, "the first case with a wrong answer")
    }

    @Test("A perfect tree of 131,071 nodes")
    func largePerfect() {
        let values: [Int?] = (0..<131_071).map { ($0 * 7_919) % 7 - 3 }
        let tree = TreeNode.make(values)
        for target in [-4, 0, 5] {
            #expect(TargetSumPaths.downwardPathCount(in: tree, summingTo: target) == referenceCount(tree, target))
            let pathsMatch = TargetSumPaths.rootToLeafPaths(in: tree, summingTo: target) == referencePaths(tree, target)
            #expect(pathsMatch, "the root-to-leaf paths for target \(target) are wrong")
        }
    }

    @Test("A random tree of 120,000 nodes with large values")
    func largeRandom() {
        var generator = SeededGenerator(state: 77)
        let tree = randomTree(120_000, values: -1_000_000_000...1_000_000_000, generator: &generator)
        let smallTree = randomTree(120_000, values: -2...2, generator: &generator)
        #expect(TargetSumPaths.downwardPathCount(in: tree, summingTo: 0) == referenceCount(tree, 0))
        #expect(TargetSumPaths.downwardPathCount(in: smallTree, summingTo: 3) == referenceCount(smallTree, 3))
        let pathsMatch = TargetSumPaths.rootToLeafPaths(in: smallTree, summingTo: 1) == referencePaths(smallTree, 1)
        #expect(pathsMatch, "the root-to-leaf paths are wrong")
    }
}
