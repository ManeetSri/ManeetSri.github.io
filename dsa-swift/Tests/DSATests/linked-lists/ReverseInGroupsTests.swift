import Testing
import DSAKit
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// The answer worked out with arrays.
private func expected(_ values: [Int], _ k: Int) -> [Int] {
    var result: [Int] = []
    var start = 0
    while start < values.count {
        let end = min(start + k, values.count)
        let group = values[start..<end]
        result += group.count == k ? Array(group.reversed()) : Array(group)
        start = end
    }
    return result
}

@Suite struct ReverseInGroupsTests {
    @Test("Reverses each whole group", arguments: [
        ([1, 2, 3, 4, 5, 6, 7, 8], 3, [3, 2, 1, 6, 5, 4, 7, 8]),
        ([1, 2, 3, 4, 5, 6], 2, [2, 1, 4, 3, 6, 5]),
        ([1, 2, 3, 4, 5], 2, [2, 1, 4, 3, 5]),
        ([1, 2, 3, 4], 4, [4, 3, 2, 1]),
        ([1, 2, 3], 4, [1, 2, 3]),
        ([1, 2, 3], 1, [1, 2, 3]),
        ([9], 1, [9]),
        ([9], 2, [9]),
    ])
    func reverses(values: [Int], k: Int, answer: [Int]) {
        #expect(ReverseInGroups.reversed(ListNode.make(values), groupSize: k)?.values == answer)
    }

    @Test("An empty list stays empty")
    func empty() {
        #expect(ReverseInGroups.reversed(nil, groupSize: 3) == nil)
    }

    @Test("Moves the nodes rather than their values")
    func movesNodes() throws {
        let head = try #require(ListNode.make([1, 2, 3, 4, 5]))
        let nodes = (0..<5).map { head.node(at: $0)! }
        let result = ReverseInGroups.reversed(head, groupSize: 2)
        let order = [1, 0, 3, 2, 4].map { nodes[$0] }
        let actual = (0..<5).compactMap { result?.node(at: $0) }
        #expect(actual.count == 5 && zip(actual, order).allSatisfy { $0 === $1 })
        #expect(nodes[4].next == nil)
    }

    @Test("Every k for every length up to 12")
    func everyCase() {
        for length in 0...12 {
            for k in 1...13 {
                let values = (0..<length).map { $0 + 1 }
                let result = ReverseInGroups.reversed(ListNode.make(values), groupSize: k)
                #expect(result?.values ?? [] == expected(values, k), "length \(length), k \(k)")
            }
        }
    }

    @Test("Stays fast on 100,000 nodes", arguments: [1, 2, 3, 1_000, 99_999, 100_000, 100_001])
    func large(k: Int) {
        let values = Array(0..<100_000)
        let result = ReverseInGroups.reversed(ListNode.make(values), groupSize: k)
        #expect(result?.values == expected(values, k))
    }
}
