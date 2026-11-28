import Testing
import DSAKit
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// The count worked out a different way: list the nodes level by level, fill in each node's largest
/// ancestor from the top down, then each subtree's largest value from the bottom up.
private func referenceCount(_ root: TreeNode?) -> Int {
    guard let root else { return 0 }
    var order = [root]
    var head = 0
    var above: [ObjectIdentifier: Int] = [:]          // the largest ancestor, for every non-root node
    while head < order.count {
        let node = order[head]
        head += 1
        let passDown = max(above[ObjectIdentifier(node)] ?? Int.min, node.value)
        for child in [node.left, node.right].compactMap({ $0 }) {
            above[ObjectIdentifier(child)] = passDown
            order.append(child)
        }
    }
    var subtreeMax: [ObjectIdentifier: Int] = [:]
    var count = 0
    for node in order.reversed() {                     // children before parents
        let below = [node.left, node.right].compactMap { $0 }.map { subtreeMax[ObjectIdentifier($0)]! }.max()
        let beatsAbove = above[ObjectIdentifier(node)].map { node.value > $0 } ?? true
        let beatsBelow = below.map { node.value > $0 } ?? true
        if beatsAbove && beatsBelow { count += 1 }
        subtreeMax[ObjectIdentifier(node)] = max(node.value, below ?? node.value)
    }
    return count
}

/// A chain of nodes holding `values` from the top down; `goesLeft(i)` says whether node i + 1 hangs to
/// the left of node i. Built with a loop.
private func chain(_ values: [Int], goesLeft: (Int) -> Bool) -> TreeNode {
    let root = TreeNode(values[0])
    var node = root
    for i in 1..<values.count {
        let child = TreeNode(values[i])
        if goesLeft(i - 1) { node.left = child } else { node.right = child }
        node = child
    }
    return root
}

/// A random tree shape with `count` nodes and values in 0..<spread: each new node hangs off a random
/// free child slot. The same every run.
private func randomTree(count: Int, spread: Int, seed: UInt64) -> TreeNode? {
    var state = seed
    func next(_ bound: Int) -> Int {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return Int(state >> 33) % bound
    }
    guard count > 0 else { return nil }
    let root = TreeNode(next(spread))
    var open: [(TreeNode, Bool)] = [(root, true), (root, false)]     // free slots: (parent, isLeft)
    for _ in 1..<count {
        let pick = next(open.count)
        let (parent, isLeft) = open[pick]
        open.swapAt(pick, open.count - 1)
        open.removeLast()
        let child = TreeNode(next(spread))
        if isLeft { parent.left = child } else { parent.right = child }
        open.append((child, true))
        open.append((child, false))
    }
    return root
}

@Suite struct LookoutNodesTests {
    @Test("The examples", arguments: [
        ([1, 2, 3, 4, 5, nil, 6, nil, nil, 7], 3),
        ([10, 4, 3], 1),
        ([5, 3, 8, 1, 4, 7, 9], 1),
        ([5, 5], 0),
        ([7], 1),
        ([], 0),
    ] as [([Int?], Int)])
    func examples(levelOrder: [Int?], expected: Int) {
        #expect(LookoutNodes.count(in: TreeNode.make(levelOrder)) == expected)
    }

    @Test("More hand-checked trees", arguments: [
        ([3, 9, 20, nil, nil, 15, 7], 2),                   // 9 and 20: 20 beats 3 above and 15, 7 below
        ([1, 2, 3, 4, 5, 6, 7], 4),                         // every leaf beats its ancestors
        ([7, 6, 5, 4, 3, 2, 1], 1),                         // only the root
        ([2, 1, 3, nil, nil, 3], 0),                        // the two 3s tie, and 1 loses to 2: none
        ([0, -1, nil, -2], 1),                              // the root beats both below it
        ([-5, -10, nil, -1], 1),                            // -1 beats -10 and -5 above it
    ] as [([Int?], Int)])
    func handChecked(levelOrder: [Int?], expected: Int) {
        #expect(LookoutNodes.count(in: TreeNode.make(levelOrder)) == expected)
    }

    @Test("Int.min and Int.max are real values")
    func extremes() {
        #expect(LookoutNodes.count(in: TreeNode(Int.min)) == 1)
        #expect(LookoutNodes.count(in: TreeNode.make([Int.min, Int.min])) == 0)
        #expect(LookoutNodes.count(in: TreeNode.make([Int.max, Int.max - 1, Int.min])) == 1)
        #expect(LookoutNodes.count(in: TreeNode.make([Int.min, Int.max])) == 1)
    }

    @Test("Matches the reference on hundreds of random trees")
    func manyRandom() {
        var failures: [String] = []
        for seed in 1...400 {
            let tree = randomTree(count: seed % 30 + 1, spread: seed % 3 == 0 ? 4 : 100, seed: UInt64(seed))
            let expected = referenceCount(tree)
            let actual = LookoutNodes.count(in: tree)
            if actual != expected && failures.count < 3 {
                failures.append("\(tree!): got \(actual), expected \(expected)")
            }
        }
        #expect(failures.isEmpty, "\(failures)")
    }

    @Test("Chains 100,000 levels deep")
    func deepChains() {
        let n = 100_000
        #expect(LookoutNodes.count(in: chain(Array(0..<n)) { _ in true }) == 1)               // only the leaf
        #expect(LookoutNodes.count(in: chain(Array((0..<n).reversed())) { _ in false }) == 1) // only the root
        #expect(LookoutNodes.count(in: chain(Array(repeating: 4, count: n)) { $0 % 2 == 0 }) == 0)
        // Values rise by 2 down the chain, except every 1,000th node dips to 0. The dips are traps for
        // code that only compares with the parent: the only lookout is the last high node, 99,998
        let dips = (0..<n).map { $0 % 1_000 == 999 ? 0 : 2 * $0 }
        #expect(LookoutNodes.count(in: chain(dips) { $0 % 3 != 0 }) == 1)
    }

    @Test("A random tree of 100,000 nodes")
    func large() {
        let tree = randomTree(count: 100_000, spread: 1_000_000, seed: 77)
        #expect(LookoutNodes.count(in: tree) == referenceCount(tree))
    }
}
