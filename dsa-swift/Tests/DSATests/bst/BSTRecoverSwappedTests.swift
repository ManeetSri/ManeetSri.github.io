import Testing
import DSAKit
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct BSTRecoverSwappedTests {
    /// 40 at the root; 20 and 60; 10, 30, 50 and 70; then 15 (right of 10) and 45 (left of 50).
    static let sample: [Int?] = [40, 20, 60, 10, 30, 50, 70, nil, 15, nil, nil, 45]

    /// Every node of `root` in level order, so tests can check that no node moved.
    static func nodes(_ root: TreeNode?) -> [ObjectIdentifier] {
        guard let root else { return [] }
        var queue = [root]
        var head = 0
        while head < queue.count {
            let node = queue[head]
            head += 1
            if let left = node.left { queue.append(left) }
            if let right = node.right { queue.append(right) }
        }
        return queue.map(ObjectIdentifier.init)
    }

    /// Swaps the values `a` and `b` in a fresh copy of `levelOrder`, repairs it, and reports whether
    /// it came back exactly as it was, with the same nodes in the same places.
    static func swapAndRepair(_ levelOrder: [Int?], _ a: Int, _ b: Int) -> Bool {
        guard let root = TreeNode.make(levelOrder), let first = root.find(a), let second = root.find(b) else {
            return false
        }
        (first.value, second.value) = (second.value, first.value)
        let before = nodes(root)
        BSTRecoverSwapped.repair(root)
        return root.levelOrder == levelOrder && nodes(root) == before
    }

    @Test("Values next to each other in sorted order", arguments: [(10, 15), (15, 20), (30, 40), (40, 45), (45, 50), (60, 70)])
    func neighbours(a: Int, b: Int) {
        #expect(Self.swapAndRepair(Self.sample, a, b))
    }

    @Test("Values far apart in sorted order", arguments: [(10, 70), (15, 60), (20, 45), (40, 70), (10, 40), (30, 50)])
    func farApart(a: Int, b: Int) {
        #expect(Self.swapAndRepair(Self.sample, a, b))
    }

    @Test("Every pair of values in a small tree")
    func everyPair() {
        let values = [10, 15, 20, 30, 40, 45, 50, 60, 70]
        var failures: [String] = []
        for i in values.indices {
            for j in (i + 1)..<values.count where !Self.swapAndRepair(Self.sample, values[i], values[j]) {
                failures.append("\(values[i]) and \(values[j])")
            }
        }
        #expect(failures == [], "the swaps that weren't repaired")
    }

    @Test("Two and three nodes, and negative values")
    func small() {
        #expect(Self.swapAndRepair([2, 1], 1, 2))
        #expect(Self.swapAndRepair([1, nil, 2], 1, 2))
        #expect(Self.swapAndRepair([2, 1, 3], 1, 3))
        #expect(Self.swapAndRepair([0, -8, 5, nil, -3], -8, 5))
        #expect(Self.swapAndRepair([0, Int.min, Int.max], Int.min, Int.max))
    }

    @Test("A chain of 1,000 nodes")
    func chain() {
        let levelOrder: [Int?] = [1] + (2...1_000).flatMap { [nil, $0] }
        #expect(Self.swapAndRepair(levelOrder, 1, 1_000))
        #expect(Self.swapAndRepair(levelOrder, 500, 501))
    }

    @Test("Swaps in a balanced tree of 131,071 nodes")
    func large() throws {
        let n = 131_071
        func build(_ low: Int, _ high: Int) -> TreeNode? {
            guard low < high else { return nil }
            let mid = (low + high) / 2
            return TreeNode(mid, left: build(low, mid), right: build(mid + 1, high))
        }
        let root = try #require(build(0, n))
        let pairs = [(0, n - 1), (0, 1), (n - 2, n - 1), (n / 2, n / 2 + 1), (n / 2, 3), (12_345, 98_765), (65_534, 65_536)]
        var wrong: [String] = []
        for (a, b) in pairs {
            guard let first = root.find(a), let second = root.find(b) else { continue }
            (first.value, second.value) = (second.value, first.value)
            BSTRecoverSwapped.repair(root)
            if root.inorder != Array(0..<n) {
                wrong.append("\(a) and \(b)")
                (first.value, second.value) = (a, b)     // put it right for the next pair
            }
        }
        #expect(wrong == [])
    }
}
