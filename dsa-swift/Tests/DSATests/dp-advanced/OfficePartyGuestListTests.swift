import DSAKit
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct PartyRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct OfficePartyGuestListTests {
    /// Every node of the tree, with the index of its parent (-1 for the root), in level order
    private func flatten(_ root: TreeNode?) -> (values: [Int], parent: [Int]) {
        guard let root else { return ([], []) }
        var nodes: [TreeNode] = [root]
        var parent = [-1]
        var head = 0
        while head < nodes.count {
            let node = nodes[head]
            for child in [node.left, node.right] {
                if let child {
                    nodes.append(child)
                    parent.append(head)
                }
            }
            head += 1
        }
        return (nodes.map(\.value), parent)
    }

    /// Brute force: try every guest list, keep the ones with no manager–report pair, take the best
    private func bruteForce(_ root: TreeNode?) -> Int {
        let (values, parent) = flatten(root)
        let n = values.count
        var best = 0
        for mask in 0..<(1 << n) {
            var total = 0
            var allowed = true
            for v in 0..<n where mask & (1 << v) != 0 {
                if parent[v] >= 0 && mask & (1 << parent[v]) != 0 {
                    allowed = false
                    break
                }
                total += values[v]
            }
            if allowed { best = max(best, total) }
        }
        return best
    }

    /// An independent DP for big trees: best(node) = max(value + best of grandchildren, best of children),
    /// filled bottom-up over the level order, so it shares no code shape with the pair-returning solution
    private func reference(_ root: TreeNode?) -> Int {
        let (values, parent) = flatten(root)
        let n = values.count
        if n == 0 { return 0 }
        var best = [Int](repeating: 0, count: n)
        var childrenSum = [Int](repeating: 0, count: n)        // sum of best over children
        var grandchildrenSum = [Int](repeating: 0, count: n)   // sum of best over grandchildren
        for v in stride(from: n - 1, through: 0, by: -1) {
            best[v] = max(values[v] + grandchildrenSum[v], childrenSum[v])
            if parent[v] >= 0 {
                childrenSum[parent[v]] += best[v]
                if parent[parent[v]] >= 0 {
                    grandchildrenSum[parent[parent[v]]] += best[v]
                }
            }
        }
        return best[0]
    }

    /// A random tree of `count` nodes: each new node hangs off a random node that still has a free slot
    private func randomTree(_ count: Int, values: ClosedRange<Int>, using random: inout PartyRandom) -> TreeNode? {
        guard count > 0 else { return nil }
        let root = TreeNode(Int.random(in: values, using: &random))
        var open: [TreeNode] = [root]
        for _ in 1..<count {
            let index = Int.random(in: 0..<open.count, using: &random)
            let parent = open[index]
            let child = TreeNode(Int.random(in: values, using: &random))
            if parent.left == nil && (parent.right != nil || Bool.random(using: &random)) {
                parent.left = child
            } else {
                parent.right = child
            }
            if parent.left != nil && parent.right != nil {
                open.swapAt(index, open.count - 1)
                open.removeLast()
            }
            open.append(child)
        }
        return root
    }

    @Test("Examples and small cases", arguments: [
        ([6, 4, 9, 7, 2, nil, 1, nil, nil, 5, 8], 29),
        ([5, 3, 4, nil, 1, nil, 2], 8),
        ([10, 1, 1, 6, 7, 3], 26),
        ([-3, -1, -2], 0),
        ([4], 4),
        ([-4], 0),
        ([1, 9, nil, 1, nil, 9], 18),
        ([0, 0, 0], 0),
    ] as [([Int?], Int)])
    func examples(levelOrder: [Int?], expected: Int) {
        #expect(OfficePartyGuestList.maximumFun(TreeNode.make(levelOrder)) == expected)
    }

    @Test("The empty org chart")
    func empty() {
        #expect(OfficePartyGuestList.maximumFun(nil) == 0)
    }

    @Test("Matches a brute force on 400 small random trees")
    func randomSmall() {
        var random = PartyRandom(seed: 58)
        for _ in 0..<400 {
            let tree = randomTree(Int.random(in: 1...14, using: &random), values: -20...30, using: &random)
            #expect(OfficePartyGuestList.maximumFun(tree) == bruteForce(tree))
        }
    }

    @Test("A perfect tree of 131,071 people")
    func perfect() {
        var values: [Int?] = []
        for i in 0..<131_071 {
            values.append((i * 7_919 + 13) % 20_001 - 10_000)
        }
        let tree = TreeNode.make(values)
        #expect(OfficePartyGuestList.maximumFun(tree) == reference(tree))
    }

    @Test("Random trees of 100,000 people")
    func randomLarge() {
        var random = PartyRandom(seed: 2_058)
        for _ in 0..<2 {
            let tree = randomTree(100_000, values: -10_000...10_000, using: &random)
            #expect(OfficePartyGuestList.maximumFun(tree) == reference(tree))
        }
    }

    @Test("A zigzag chain 400 levels deep")
    func zigzag() {
        let root = TreeNode(1)
        var node = root
        for level in 1..<400 {
            let child = TreeNode(level % 3 == 0 ? 50 : level)
            if level.isMultiple(of: 2) { node.left = child } else { node.right = child }
            node = child
        }
        #expect(OfficePartyGuestList.maximumFun(root) == reference(root))
    }
}
