import Testing
import DSAKit
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct RemoveKthFromEndTests {
    @Test("Removes the kth node from the end", arguments: [
        ([1, 2, 3, 4, 5], 2, [1, 2, 3, 5]),
        ([1, 2, 3, 4, 5], 1, [1, 2, 3, 4]),
        ([1, 2, 3, 4, 5], 5, [2, 3, 4, 5]),
        ([1, 2], 1, [1]),
        ([1, 2], 2, [2]),
        ([8, 8, 8], 2, [8, 8]),
    ])
    func removes(values: [Int], k: Int, expected: [Int]) {
        #expect(RemoveKthFromEnd.removing(ListNode.make(values), kthFromEnd: k)?.values == expected)
    }

    @Test("Removing the only node leaves an empty list")
    func onlyNode() {
        #expect(RemoveKthFromEnd.removing(ListNode(4), kthFromEnd: 1) == nil)
    }

    @Test("Every k for every length up to 10, keeping the original nodes")
    func everyCase() throws {
        for length in 1...10 {
            for k in 1...length {
                let values = Array(1...length)
                let head = try #require(ListNode.make(values))
                let survivors = (0..<length).filter { $0 != length - k }.map { head.node(at: $0)! }
                var expected = values
                expected.remove(at: length - k)

                let result = RemoveKthFromEnd.removing(head, kthFromEnd: k)
                #expect(result?.values ?? [] == expected, "length \(length), k \(k)")
                let kept = (0..<expected.count).compactMap { result?.node(at: $0) }
                #expect(kept.count == survivors.count && zip(kept, survivors).allSatisfy { $0 === $1 },
                        "the remaining nodes should be the original ones, not copies")
            }
        }
    }

    @Test("Stays fast on 100,000 nodes", arguments: [1, 2, 50_000, 99_999, 100_000])
    func large(k: Int) {
        var expected = Array(0..<100_000)
        expected.remove(at: 100_000 - k)
        let result = RemoveKthFromEnd.removing(ListNode.make(Array(0..<100_000)), kthFromEnd: k)
        #expect(result?.values == expected)
    }
}
