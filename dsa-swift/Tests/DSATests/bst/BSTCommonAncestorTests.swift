import Testing
import DSAKit
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct BSTCommonAncestorTests {
    /// 40 at the root; 20 and 60; 10, 30, 50 and 70; then 15 (right of 10) and 45 (left of 50).
    static let sample: [Int?] = [40, 20, 60, 10, 30, 50, 70, nil, 15, nil, nil, 45]

    @Test("Values that split at a node", arguments: [
        (10, 30, 20), (15, 30, 20), (15, 45, 40), (45, 70, 60), (10, 70, 40), (30, 50, 40), (30, 10, 20),
    ])
    func splits(first: Int, second: Int, expected: Int) throws {
        let root = try #require(TreeNode.make(Self.sample))
        let ancestor = BSTCommonAncestor.lowest(of: first, and: second, in: root)
        #expect(ancestor?.value == expected)
        #expect(ancestor === root.find(expected))
    }

    @Test("A node is its own ancestor", arguments: [
        (10, 15, 10), (15, 10, 10), (40, 45, 40), (50, 45, 50), (60, 70, 60), (20, 15, 20),
    ])
    func ownAncestor(first: Int, second: Int, expected: Int) throws {
        let root = try #require(TreeNode.make(Self.sample))
        #expect(BSTCommonAncestor.lowest(of: first, and: second, in: root) === root.find(expected))
    }

    @Test("Both values the same", arguments: [40, 15, 45, 70])
    func same(value: Int) throws {
        let root = try #require(TreeNode.make(Self.sample))
        #expect(BSTCommonAncestor.lowest(of: value, and: value, in: root) === root.find(value))
    }

    @Test("A single node, and a chain")
    func smallShapes() throws {
        let single = TreeNode(5)
        #expect(BSTCommonAncestor.lowest(of: 5, and: 5, in: single) === single)
        let chain = try #require(TreeNode.make([1, nil, 2, nil, 3, nil, 4, nil, 5]))
        #expect(BSTCommonAncestor.lowest(of: 3, and: 5, in: chain)?.value == 3)
        #expect(BSTCommonAncestor.lowest(of: 5, and: 1, in: chain)?.value == 1)
    }

    @Test("Extreme values")
    func extremes() throws {
        let root = try #require(TreeNode.make([0, Int.min, Int.max, nil, -1, 1]))
        #expect(BSTCommonAncestor.lowest(of: Int.min, and: -1, in: root)?.value == Int.min)
        #expect(BSTCommonAncestor.lowest(of: -1, and: 1, in: root)?.value == 0)
        #expect(BSTCommonAncestor.lowest(of: Int.max, and: 1, in: root)?.value == Int.max)
    }

    @Test("20,000 queries in a balanced tree of 131,071 nodes")
    func large() throws {
        let n = 131_071
        func build(_ low: Int, _ high: Int) -> TreeNode? {
            guard low < high else { return nil }
            let mid = (low + high) / 2
            return TreeNode(mid, left: build(low, mid), right: build(mid + 1, high))
        }
        let root = try #require(build(0, n))
        // The expected answer comes from the ranges the tree was built from: the first middle value
        // that isn't entirely left or right of both values.
        func expected(_ a: Int, _ b: Int) -> Int {
            var low = 0
            var high = n
            while true {
                let mid = (low + high) / 2
                if Swift.max(a, b) < mid {
                    high = mid
                } else if Swift.min(a, b) > mid {
                    low = mid + 1
                } else {
                    return mid
                }
            }
        }
        var a = 0
        var b = 0
        var wrong = 0
        for _ in 0..<20_000 {
            a = (a + 7_919) % n
            b = (b * 31 + 17) % n
            if BSTCommonAncestor.lowest(of: a, and: b, in: root)?.value != expected(a, b) {
                wrong += 1
            }
        }
        #expect(wrong == 0)
    }
}
