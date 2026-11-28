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

/// A tree of `count` nodes in a random shape, holding the values 0 to count − 1.
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

/// The parent-pointer method: collect the first node's ancestors, then climb from the second node until
/// reaching one of them.
private func referenceAncestor(_ first: TreeNode, _ second: TreeNode, parent: [ObjectIdentifier: TreeNode]) -> TreeNode {
    var ancestors: Set<ObjectIdentifier> = []
    var node: TreeNode? = first
    while let current = node {
        ancestors.insert(ObjectIdentifier(current))
        node = parent[ObjectIdentifier(current)]
    }
    var climber = second
    while !ancestors.contains(ObjectIdentifier(climber)) {
        climber = parent[ObjectIdentifier(climber)]!
    }
    return climber
}

private func parents(of root: TreeNode?) -> [ObjectIdentifier: TreeNode] {
    var parent: [ObjectIdentifier: TreeNode] = [:]
    for node in nodes(of: root) {
        for child in [node.left, node.right].compactMap({ $0 }) {
            parent[ObjectIdentifier(child)] = node
        }
    }
    return parent
}

@Suite struct DeepestSharedAncestorTests {
    static let example: [Int?] = [10, 4, 7, 1, 9, nil, 3, nil, nil, 5, 8]

    @Test("The examples", arguments: [
        (5, 8, 9), (5, 1, 4), (5, 3, 10), (9, 8, 9), (8, 9, 9), (7, 7, 7), (1, 10, 10), (3, 7, 7),
    ])
    func examples(first: Int, second: Int, expected: Int) throws {
        let tree = try #require(TreeNode.make(Self.example))
        let a = try #require(tree.find(first))
        let b = try #require(tree.find(second))
        let answer = DeepestSharedAncestor.lowestCommonAncestor(of: a, and: b, in: tree)
        #expect(answer === tree.find(expected), "expected the node holding \(expected), got \(answer?.value as Any)")
    }

    @Test("The answer is a node of the tree, not just a node with the right value")
    func identity() throws {
        // Values repeat here, so only the right node object will do
        let tree = try #require(TreeNode.make([1, 1, 1, 1, 1, 1, 1]))
        let leftLeaf = try #require(tree.left?.left)
        let leftRightLeaf = try #require(tree.left?.right)
        let rightLeaf = try #require(tree.right?.right)
        #expect(DeepestSharedAncestor.lowestCommonAncestor(of: leftLeaf, and: leftRightLeaf, in: tree) === tree.left)
        #expect(DeepestSharedAncestor.lowestCommonAncestor(of: leftLeaf, and: rightLeaf, in: tree) === tree)
    }

    @Test("Every pair of nodes in 40 random trees")
    func randomTrees() {
        var generator = SeededGenerator(state: 21)
        var wrong = 0
        var firstMismatch: String? = nil
        for round in 1...40 {
            let tree = randomTree(round % 25 + 1, generator: &generator)
            let all = nodes(of: tree)
            let parent = parents(of: tree)
            for a in all {
                for b in all where DeepestSharedAncestor.lowestCommonAncestor(of: a, and: b, in: tree) !== referenceAncestor(a, b, parent: parent) {
                    wrong += 1
                    firstMismatch = firstMismatch ?? "\(a.value) and \(b.value) in \(tree!.description)"
                }
            }
        }
        #expect(wrong == 0, "the first pair with a wrong answer: \(firstMismatch ?? "none")")
    }

    @Test("30 pairs in a perfect tree of 131,071 nodes")
    func largePerfect() {
        // Values are positions in level order from 1, so the parent of value v holds v / 2
        let tree = TreeNode.make(Array(1...131_071))
        let byValue = [nil] + nodes(of: tree).map { Optional($0) }     // byValue[v] holds v
        var generator = SeededGenerator(state: 4)
        var wrong = 0
        for _ in 0..<30 {
            var a = Int.random(in: 1...131_071, using: &generator)
            var b = Int.random(in: 1...131_071, using: &generator)
            let nodeA = byValue[a]!
            let nodeB = byValue[b]!
            while a != b {
                if a > b { a /= 2 } else { b /= 2 }
            }
            if DeepestSharedAncestor.lowestCommonAncestor(of: nodeA, and: nodeB, in: tree) !== byValue[a] {
                wrong += 1
            }
        }
        #expect(wrong == 0)
    }

    @Test("A random tree of 120,000 nodes")
    func largeRandom() {
        var generator = SeededGenerator(state: 12)
        let tree = randomTree(120_000, generator: &generator)
        let all = nodes(of: tree)
        let parent = parents(of: tree)
        var wrong = 0
        for _ in 0..<20 {
            let a = all[Int.random(in: 0..<all.count, using: &generator)]
            let b = all[Int.random(in: 0..<all.count, using: &generator)]
            if DeepestSharedAncestor.lowestCommonAncestor(of: a, and: b, in: tree) !== referenceAncestor(a, b, parent: parent) {
                wrong += 1
            }
        }
        #expect(wrong == 0)
    }

    @Test("A chain 500 nodes deep, with a branch at the bottom")
    func deepChain() throws {
        var top = TreeNode(0, left: TreeNode(-1), right: TreeNode(-2))
        let bottom = top
        for value in 1..<500 {
            top = TreeNode(value, left: value % 2 == 0 ? top : nil, right: value % 2 == 0 ? nil : top)
        }
        let leftLeaf = try #require(bottom.left)
        let rightLeaf = try #require(bottom.right)
        let bottomIsAnswer = DeepestSharedAncestor.lowestCommonAncestor(of: leftLeaf, and: rightLeaf, in: top) === bottom
        #expect(bottomIsAnswer, "the two leaves meet at the bottom of the chain")
        let topIsAnswer = DeepestSharedAncestor.lowestCommonAncestor(of: top, and: rightLeaf, in: top) === top
        #expect(topIsAnswer, "the top of the chain is an ancestor of everything")
    }
}
