import Testing
import DSAKit
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

private typealias LevelNode = FlattenAndLinkLevels.LevelNode

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

/// A tree of `count` nodes in a random shape, holding 0 to count − 1.
private func randomTree(_ count: Int, generator: inout SeededGenerator) -> TreeNode? {
    guard count > 0 else { return nil }
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

/// The nodes in preorder, with an explicit stack.
private func preorderNodes(_ root: TreeNode?) -> [TreeNode] {
    var result: [TreeNode] = []
    var pending: [TreeNode] = root.map { [$0] } ?? []
    while let node = pending.popLast() {
        result.append(node)
        if let right = node.right { pending.append(right) }
        if let left = node.left { pending.append(left) }
    }
    return result
}

/// Checks that flattening rewired `tree` into its preorder chain, and describes the first problem.
private func flattenProblem(_ tree: TreeNode?) -> String? {
    let expected = preorderNodes(tree).map(ObjectIdentifier.init)
    FlattenAndLinkLevels.flatten(tree)
    var chain: [ObjectIdentifier] = []
    var current = tree
    while let node = current, chain.count <= expected.count {
        if node.left != nil { return "a node still has a left child" }
        chain.append(ObjectIdentifier(node))
        current = node.right
    }
    return chain == expected ? nil : "the right links don't follow the original preorder"
}

/// A LevelNode copy of a tree.
private func levelTree(_ node: TreeNode?) -> LevelNode? {
    guard let node else { return nil }
    return LevelNode(node.value, left: levelTree(node.left), right: levelTree(node.right))
}

/// The tree's levels, found through left and right only.
private func levels(_ root: LevelNode?) -> [[LevelNode]] {
    var result: [[LevelNode]] = []
    var level: [LevelNode] = root.map { [$0] } ?? []
    while !level.isEmpty {
        result.append(level)
        level = level.flatMap { [$0.left, $0.right].compactMap { $0 } }
    }
    return result
}

/// Checks every node's next link after linking, and that the children didn't change.
private func linkProblem(_ root: LevelNode?) -> String? {
    let before = levels(root).map { $0.map(ObjectIdentifier.init) }
    FlattenAndLinkLevels.linkLevels(root)
    let after = levels(root)
    if after.map({ $0.map(ObjectIdentifier.init) }) != before {
        return "left and right links changed"
    }
    for (depth, level) in after.enumerated() {
        for (index, node) in level.enumerated() {
            let expected = index + 1 < level.count ? level[index + 1] : nil
            if node.next !== expected {
                return "level \(depth), node \(index) (value \(node.value)) has the wrong next"
            }
        }
    }
    return nil
}

@Suite struct FlattenAndLinkLevelsTests {
    // MARK: flatten

    @Test("Flattening the example gives the preorder chain")
    func flattenExample() throws {
        let tree = try #require(TreeNode.make([1, 2, 6, 3, 4, nil, 7, nil, nil, 5]))
        FlattenAndLinkLevels.flatten(tree)
        #expect(tree.levelOrder == [1, nil, 2, nil, 3, nil, 4, nil, 5, nil, 6, nil, 7])
    }

    @Test("Flattening small shapes", arguments: [
        [1], [1, 2], [1, nil, 2], [1, 2, 3], [4, 3, nil, 2, nil, 1], [1, 2, 3, 4, 5, 6, 7], [5, nil, 6, 7, 8],
    ] as [[Int?]])
    func flattenShapes(levelOrder: [Int?]) {
        #expect(flattenProblem(TreeNode.make(levelOrder)) == nil)
    }

    @Test("Flattening the empty tree does nothing")
    func flattenEmpty() {
        FlattenAndLinkLevels.flatten(nil)
    }

    @Test("Flattening 300 random trees reuses every node in preorder")
    func flattenRandom() {
        var generator = SeededGenerator(state: 14)
        var firstProblem: String? = nil
        for round in 0..<300 {
            firstProblem = firstProblem ?? flattenProblem(randomTree(round % 60, generator: &generator))
        }
        #expect(firstProblem == nil)
    }

    @Test("Flattening large trees: 131,071 perfect, 150,000 random, and a 500-deep left chain")
    func flattenLarge() {
        let perfect = TreeNode.make(Array(1...131_071))
        #expect(flattenProblem(perfect) == nil)
        var generator = SeededGenerator(state: 15)
        let random = randomTree(150_000, generator: &generator)
        #expect(flattenProblem(random) == nil)
        var top: TreeNode? = nil
        for value in 0..<500 {
            top = TreeNode(value, left: top)
        }
        #expect(flattenProblem(top) == nil)
    }

    // MARK: linkLevels

    @Test("Linking a perfect tree of 7")
    func linkPerfect() throws {
        let root = try #require(levelTree(TreeNode.make([1, 2, 3, 4, 5, 6, 7])))
        FlattenAndLinkLevels.linkLevels(root)
        #expect(root.next == nil)
        #expect(root.left?.next === root.right)
        #expect(root.right?.next == nil)
        #expect(root.left?.left?.next?.value == 5)
        #expect(root.left?.right?.next?.value == 6)
        #expect(root.right?.left?.next?.value == 7)
        #expect(root.right?.right?.next == nil)
    }

    @Test("Links jump over gaps between cousins")
    func linkAcrossGaps() throws {
        let root = try #require(levelTree(TreeNode.make([1, 2, 3, 4, nil, nil, 5])))
        FlattenAndLinkLevels.linkLevels(root)
        #expect(root.left?.left?.next === root.right?.right)
    }

    @Test("Linking small shapes", arguments: [
        [1], [1, 2], [1, nil, 2], [1, 2, 3, nil, 4, 5], [1, 2, 3, 4, nil, nil, 5, 6, nil, nil, 7], [1, nil, 2, 3, nil, nil, 4],
    ] as [[Int?]])
    func linkShapes(levelOrder: [Int?]) {
        #expect(linkProblem(levelTree(TreeNode.make(levelOrder))) == nil)
    }

    @Test("Linking the empty tree does nothing")
    func linkEmpty() {
        FlattenAndLinkLevels.linkLevels(nil)
    }

    @Test("Linking 300 random trees")
    func linkRandom() {
        var generator = SeededGenerator(state: 16)
        var firstProblem: String? = nil
        for round in 0..<300 {
            firstProblem = firstProblem ?? linkProblem(levelTree(randomTree(round % 60, generator: &generator)))
        }
        #expect(firstProblem == nil)
    }

    @Test("Linking large trees: 131,071 perfect and 150,000 random")
    func linkLarge() {
        let perfect = levelTree(TreeNode.make(Array(1...131_071)))
        #expect(linkProblem(perfect) == nil)
        var generator = SeededGenerator(state: 17)
        let random = levelTree(randomTree(150_000, generator: &generator))
        #expect(linkProblem(random) == nil)
    }
}
