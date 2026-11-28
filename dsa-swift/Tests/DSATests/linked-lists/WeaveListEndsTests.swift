import Testing
import DSAKit
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct WeaveListEndsTests {
    /// The positions of the original nodes in woven order: 0, n - 1, 1, n - 2, ...
    private func wovenOrder(_ count: Int) -> [Int] {
        var order: [Int] = []
        var left = 0
        var right = count - 1
        while left <= right {
            order.append(left)
            if left != right { order.append(right) }
            left += 1
            right -= 1
        }
        return order
    }

    @Test("Alternates front and back", arguments: [
        ([1, 2, 3, 4, 5], [1, 5, 2, 4, 3]),
        ([10, 20, 30, 40], [10, 40, 20, 30]),
        ([8, 9], [8, 9]),
        ([4], [4]),
        ([1, 2, 3], [1, 3, 2]),
        ([6, 6, 7, 7, 6, 6], [6, 6, 6, 6, 7, 7]),
    ])
    func reorders(values: [Int], expected: [Int]) {
        let head = ListNode.make(values)
        WeaveListEnds.reorder(head)
        #expect(head?.values == expected)
    }

    @Test("An empty list stays empty")
    func empty() {
        WeaveListEnds.reorder(nil)
        #expect(Bool(true))
    }

    @Test("Rewires the original nodes for every length up to 12")
    func keepsNodes() throws {
        for length in 1...12 {
            let head = try #require(ListNode.make(Array(0..<length)))
            let originals = (0..<length).map { head.node(at: $0)! }
            WeaveListEnds.reorder(head)
            let order = wovenOrder(length)
            #expect(head.values == order, "length \(length)")
            let rewired = (0..<length).allSatisfy { head.node(at: $0) === originals[order[$0]] }
            #expect(rewired && head.count == length, "length \(length): reuse the original nodes, and end the list")
        }
    }

    @Test("Stays O(n) on 20,000 nodes")
    func large() {
        let head = ListNode.make(Array(0..<20_000))
        WeaveListEnds.reorder(head)
        #expect(head?.values == wovenOrder(20_000))
    }
}
