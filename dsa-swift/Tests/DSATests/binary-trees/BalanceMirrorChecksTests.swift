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

/// A tree of `count` nodes in a random shape, with values from `values`: each new node walks down from
/// the root, turning left or right at random, until it finds a free place.
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

/// Balance worked out without recursion: children's heights before parents', in reverse level order.
private func referenceIsBalanced(_ root: TreeNode?) -> Bool {
    var height: [ObjectIdentifier: Int] = [:]
    for node in nodes(of: root).reversed() {
        let left = node.left.map { height[ObjectIdentifier($0)]! } ?? 0
        let right = node.right.map { height[ObjectIdentifier($0)]! } ?? 0
        if abs(left - right) > 1 { return false }
        height[ObjectIdentifier(node)] = 1 + max(left, right)
    }
    return true
}

/// A brand-new copy of a tree.
private func copy(_ node: TreeNode?) -> TreeNode? {
    guard let node else { return nil }
    return TreeNode(node.value, left: copy(node.left), right: copy(node.right))
}

/// The slow, obvious subtree check: compare the pattern with the subtree at every node.
private func referenceContains(_ pattern: TreeNode?, in tree: TreeNode?) -> Bool {
    func same(_ a: TreeNode?, _ b: TreeNode?) -> Bool {
        if a == nil && b == nil { return true }
        guard let a, let b else { return false }
        return a.value == b.value && same(a.left, b.left) && same(a.right, b.right)
    }
    guard pattern != nil else { return true }
    return nodes(of: tree).contains { same($0, pattern) }
}

/// A tree whose every node's subtrees differ in height by exactly 1 (except at the leaves): the most
/// lopsided tree that's still balanced. `levels` levels tall.
private func fibonacciTree(_ levels: Int, next: inout Int) -> TreeNode? {
    guard levels > 0 else { return nil }
    next += 1
    let node = TreeNode(next)
    node.left = fibonacciTree(levels - 1, next: &next)
    node.right = fibonacciTree(levels - 2, next: &next)
    return node
}

/// Level order of a perfect tree whose values mirror within each level, so the tree is symmetric.
private func symmetricLevelOrder(levels: Int) -> [Int?] {
    var values: [Int?] = []
    for level in 0..<levels {
        let width = 1 << level
        for i in 0..<width {
            values.append(min(i, width - 1 - i) % 7)
        }
    }
    return values
}

@Suite struct BalanceMirrorChecksTests {
    // MARK: isBalanced

    @Test("Balanced trees", arguments: [
        [], [1], [5, 2, 8, nil, nil, 6, 9], [1, 2, 3, 4], [1, 2, 3, 4, 5, 6, 7], [1, 2, 3, nil, 4, nil, 5],
    ] as [[Int?]])
    func balanced(levelOrder: [Int?]) {
        #expect(BalanceMirrorChecks.isBalanced(TreeNode.make(levelOrder)))
    }

    @Test("Unbalanced trees, including ones whose root looks fine", arguments: [
        [1, 2, nil, 3],
        [1, 2, 3, 4, 5, nil, nil, 6],
        [1, 2, 2, 3, nil, nil, 3, 4, nil, nil, 4],
        [1, nil, 2, nil, 3],
    ] as [[Int?]])
    func unbalanced(levelOrder: [Int?]) {
        #expect(!BalanceMirrorChecks.isBalanced(TreeNode.make(levelOrder)))
    }

    @Test("Large balanced trees: perfect, complete and as lopsided as allowed")
    func largeBalanced() {
        // (Large trees go into a Bool first, so a failure doesn't print the whole tree.)
        let perfect = BalanceMirrorChecks.isBalanced(TreeNode.make(Array(1...131_071)))
        #expect(perfect, "a perfect tree is balanced")
        let complete = BalanceMirrorChecks.isBalanced(TreeNode.make(Array(1...100_000)))
        #expect(complete, "a complete tree is balanced")
        var next = 0
        let fibonacci = BalanceMirrorChecks.isBalanced(fibonacciTree(25, next: &next))    // 121,392 nodes
        #expect(fibonacci, "every node's subtrees differ by exactly 1 level here")
    }

    @Test("A large tree with one problem at the bottom")
    func largeUnbalanced() throws {
        let tree = try #require(TreeNode.make(Array(1...131_071)))
        var leaf = tree
        while let left = leaf.left { leaf = left }
        leaf.left = TreeNode(0, left: TreeNode(0))           // two more levels under one leaf
        let balanced = BalanceMirrorChecks.isBalanced(tree)
        #expect(!balanced, "the leaf's parent has subtrees of 3 levels and 1 level")
    }

    @Test("Matches a careful check on 400 random trees")
    func randomBalance() {
        var generator = SeededGenerator(state: 11)
        var firstMismatch: String? = nil
        var balancedCount = 0
        for size in 0..<400 {
            let tree = randomTree(size % 12, values: 0...9, generator: &generator)
            let expected = referenceIsBalanced(tree)
            balancedCount += expected ? 1 : 0
            if BalanceMirrorChecks.isBalanced(tree) != expected {
                firstMismatch = firstMismatch ?? (tree?.description ?? "[]")
            }
        }
        #expect(firstMismatch == nil, "the first tree with a wrong answer")
        #expect(balancedCount > 50)                          // the test itself covers both answers
    }

    // MARK: isSymmetric

    @Test("Symmetric trees", arguments: [
        [], [1], [1, 2, 2], [1, 2, 2, 3, 4, 4, 3], [1, 2, 2, nil, 3, 3], [0, -4, -4, 5, nil, nil, 5],
    ] as [[Int?]])
    func symmetric(levelOrder: [Int?]) {
        #expect(BalanceMirrorChecks.isSymmetric(TreeNode.make(levelOrder)))
    }

    @Test("Trees that aren't symmetric", arguments: [
        [1, 2, 3], [1, 2, 2, nil, 3, nil, 3], [1, 2, 2, 3, nil, 3], [1, 2], [1, 2, 2, 3, 4, 3, 4],
    ] as [[Int?]])
    func notSymmetric(levelOrder: [Int?]) {
        #expect(!BalanceMirrorChecks.isSymmetric(TreeNode.make(levelOrder)))
    }

    @Test("A symmetric tree of 131,071 nodes, then one changed value deep down")
    func largeSymmetric() throws {
        let values = symmetricLevelOrder(levels: 17)
        let symmetric = BalanceMirrorChecks.isSymmetric(TreeNode.make(values))
        #expect(symmetric, "each level's values read the same backwards")
        var changed = values
        changed[values.count - 5] = 100
        let stillSymmetric = BalanceMirrorChecks.isSymmetric(TreeNode.make(changed))
        #expect(!stillSymmetric, "one value on the bottom level changed")
    }

    // MARK: mirrored

    @Test("Mirroring the examples", arguments: [
        ([6, 3, 8, 1, 4, 7, 9], [6, 8, 3, 9, 7, 4, 1]),
        ([1, 2], [1, nil, 2]),
        ([5, 3, nil, nil, 4], [5, nil, 3, 4]),
        ([8], [8]),
    ] as [([Int?], [Int?])])
    func mirrors(levelOrder: [Int?], expected: [Int?]) {
        #expect(BalanceMirrorChecks.mirrored(TreeNode.make(levelOrder))?.levelOrder == expected)
    }

    @Test("Mirroring the empty tree gives the empty tree")
    func mirrorEmpty() {
        #expect(BalanceMirrorChecks.mirrored(nil) == nil)
    }

    @Test("Mirroring reuses the nodes and returns the same root")
    func mirrorReusesNodes() throws {
        let tree = try #require(TreeNode.make([1, 2, 3, 4, 5, 6, 7, nil, 8]))
        let before = Set(nodes(of: tree).map(ObjectIdentifier.init))
        let result = BalanceMirrorChecks.mirrored(tree)
        #expect(result === tree)
        #expect(Set(nodes(of: result).map(ObjectIdentifier.init)) == before)
    }

    @Test("Mirroring twice gives back the original, on 200 random trees")
    func mirrorTwice() {
        var generator = SeededGenerator(state: 5)
        var firstMismatch: String? = nil
        for size in 0..<200 {
            let tree = randomTree(size % 30, values: -9...9, generator: &generator)
            let original = tree?.levelOrder ?? []
            BalanceMirrorChecks.mirrored(tree)
            BalanceMirrorChecks.mirrored(tree)
            if (tree?.levelOrder ?? []) != original {
                firstMismatch = firstMismatch ?? "\(original)"
            }
        }
        #expect(firstMismatch == nil, "the first tree that didn't come back")
    }

    @Test("Mirroring a perfect tree of 131,071 nodes reverses every level")
    func mirrorLarge() {
        let tree = TreeNode.make(Array(1...131_071))
        var expected: [Int?] = []
        for level in 0..<17 {
            let first = 1 << level
            expected += Array((first..<(2 * first)).reversed())
        }
        let matches = BalanceMirrorChecks.mirrored(tree)?.levelOrder == expected
        #expect(matches, "every level should come back reversed")
    }

    // MARK: contains

    @Test("Subtree examples", arguments: [
        ([7, 2, 9, 1, 5], [2, 1, 5], true),
        ([7, 2, 9, 1, 5, nil, nil, nil, nil, 4], [2, 1, 5], false),
        ([7, 2, 9, 1, 5], [7, 2, 9, 1, 5], true),
        ([7, 2, 9, 1, 5], [9], true),
        ([7, 2, 9, 1, 5], [7], false),
        ([7, 2, 9, 1, 5], [2, 1], false),
        ([1, 1, 1, nil, 1, nil, 1, 1], [1, nil, 1, 1], true),
        ([4, 4, nil, 4, nil, 4], [4, 4, 4], false),
        ([], [3], false),
    ] as [([Int?], [Int?], Bool)])
    func subtrees(tree: [Int?], pattern: [Int?], expected: Bool) {
        #expect(BalanceMirrorChecks.contains(TreeNode.make(pattern), in: TreeNode.make(tree)) == expected)
    }

    @Test("An empty pattern is inside every tree")
    func emptyPattern() {
        #expect(BalanceMirrorChecks.contains(nil, in: TreeNode.make([1, 2])))
        #expect(BalanceMirrorChecks.contains(nil, in: nil))
    }

    @Test("Matches the slow check on 500 random trees with many repeated values")
    func randomSubtrees() {
        var generator = SeededGenerator(state: 99)
        var firstMismatch: String? = nil
        var foundCount = 0
        for round in 0..<500 {
            let tree = randomTree(round % 40, values: 0...1, generator: &generator)
            let all = nodes(of: tree)
            let pattern: TreeNode?
            if round % 2 == 0 && !all.isEmpty {
                pattern = copy(all[Int.random(in: 0..<all.count, using: &generator)])
            } else {
                pattern = randomTree(round % 5 + 1, values: 0...1, generator: &generator)
            }
            let expected = referenceContains(pattern, in: tree)
            foundCount += expected ? 1 : 0
            if BalanceMirrorChecks.contains(pattern, in: tree) != expected {
                firstMismatch = firstMismatch ?? "pattern \(pattern?.description ?? "[]") in \(tree?.description ?? "[]")"
            }
        }
        #expect(firstMismatch == nil, "the first case with a wrong answer")
        #expect(foundCount > 100 && foundCount < 490)          // the test itself covers both answers
    }

    @Test("131,071 nodes of all zeros, and a pattern that almost matches everywhere")
    func largeNearMisses() {
        let tree = TreeNode.make(Array(repeating: 0, count: 131_071))
        var pattern = Array(repeating: 0, count: 15) as [Int?]
        let found = BalanceMirrorChecks.contains(TreeNode.make(pattern), in: tree)
        #expect(found, "the bottom four levels hold many copies of the pattern")
        pattern[14] = 1                                      // the last leaf differs
        let foundChanged = BalanceMirrorChecks.contains(TreeNode.make(pattern), in: tree)
        #expect(!foundChanged, "no node holds a 1")
    }

    @Test("Finds a copy of a subtree near the bottom right of 131,071 nodes")
    func largeFound() throws {
        let tree = try #require(TreeNode.make(Array(1...131_071)))
        var node = tree
        for _ in 0..<12 {
            node = try #require(node.right)
        }
        let pattern = copy(node)
        let found = BalanceMirrorChecks.contains(pattern, in: tree)
        #expect(found, "the pattern is a copy of a subtree")
        node.right?.right?.value = -1                        // change the tree, not the copy
        let foundAfterChange = BalanceMirrorChecks.contains(pattern, in: tree)
        #expect(!foundAfterChange, "the only matching subtree has changed")
    }
}
