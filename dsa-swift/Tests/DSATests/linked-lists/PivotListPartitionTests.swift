import Testing
import DSAKit
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct PivotListPartitionTests {
    /// A tiny deterministic generator, so the random cases are the same every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    @Test("Puts the smaller values first, keeping each group's order", arguments: [
        ([4, 1, 7, 3, 5, 2], 4, [1, 3, 2, 4, 7, 5]),
        ([3, 1, 2], 5, [3, 1, 2]),
        ([3, 1, 2], 0, [3, 1, 2]),
        ([9, 2, 9, 2], 9, [2, 2, 9, 9]),
        ([1], 1, [1]),
        ([5, 4], 5, [4, 5]),
        ([-1, 0, -2, 1], 0, [-1, -2, 0, 1]),
    ])
    func partitions(values: [Int], pivot: Int, expected: [Int]) {
        #expect(PivotListPartition.partitioned(ListNode.make(values), around: pivot)?.values == expected)
    }

    @Test("An empty list stays empty")
    func empty() {
        #expect(PivotListPartition.partitioned(nil, around: 1) == nil)
    }

    @Test("Rewires the original nodes, stably, on random lists")
    func keepsNodes() throws {
        var steps = Steps(seed: 25)
        var failures = 0
        for _ in 0..<200 {
            let values = (0..<(1 + steps.next(below: 12))).map { _ in steps.next(below: 6) }
            let pivot = steps.next(below: 7)
            let head = try #require(ListNode.make(values))
            let originals = values.indices.map { head.node(at: $0)! }
            let order = values.indices.filter { values[$0] < pivot } + values.indices.filter { values[$0] >= pivot }
            let result = PivotListPartition.partitioned(head, around: pivot)
            let rewired = order.indices.allSatisfy { result?.node(at: $0) === originals[order[$0]] }
            if !rewired || result?.count != values.count { failures += 1 }
        }
        #expect(failures == 0)
    }

    @Test("Stays O(n) on 20,000 nodes")
    func large() {
        let values = (0..<20_000).map { ($0 * 7_919) % 20_000 }
        let expected = values.filter { $0 < 10_000 } + values.filter { $0 >= 10_000 }
        #expect(PivotListPartition.partitioned(ListNode.make(values), around: 10_000)?.values == expected)
    }
}
