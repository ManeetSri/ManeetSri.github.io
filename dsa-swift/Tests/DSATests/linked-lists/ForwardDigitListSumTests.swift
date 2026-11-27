import Testing
import DSAKit
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ForwardDigitListSumTests {
    /// The digits of a non-negative Int, most significant first.
    private func digits(_ number: Int) -> [Int] {
        String(number).map { $0.wholeNumberValue! }
    }

    @Test("Adds from the far end", arguments: [
        ([7, 2, 4, 3], [5, 6, 4], [7, 8, 0, 7]),
        ([9, 9], [1], [1, 0, 0]),
        ([5], [5], [1, 0]),
        ([3, 0, 1], [0], [3, 0, 1]),
        ([0], [0], [0]),
        ([1], [9, 9, 9, 9], [1, 0, 0, 0, 0]),
        ([4, 5], [5, 4], [9, 9]),
    ])
    func adds(first: [Int], second: [Int], expected: [Int]) {
        #expect(ForwardDigitListSum.add(ListNode.make(first), ListNode.make(second))?.values == expected)
    }

    @Test("Agrees with Int addition")
    func matchesInts() {
        var mismatches = 0
        for x in stride(from: 0, through: 2_000, by: 37) {
            for y in [0, 1, 9, 99, 100, 512, 999, 1_001, 98_765] {
                if ForwardDigitListSum.add(ListNode.make(digits(x)), ListNode.make(digits(y)))?.values != digits(x + y) {
                    mismatches += 1
                }
            }
        }
        #expect(mismatches == 0)
    }

    @Test("Leaves both inputs exactly as they were")
    func inputsUnchanged() throws {
        let first = try #require(ListNode.make([7, 2, 4, 3]))
        let second = try #require(ListNode.make([5, 6, 4]))
        let firstNodes = (0..<4).map { first.node(at: $0)! }
        let secondNodes = (0..<3).map { second.node(at: $0)! }
        let result = ForwardDigitListSum.add(first, second)
        #expect(result?.values == [7, 8, 0, 7])
        #expect(first.values == [7, 2, 4, 3] && second.values == [5, 6, 4])
        #expect((0..<4).allSatisfy { first.node(at: $0) === firstNodes[$0] })
        #expect((0..<3).allSatisfy { second.node(at: $0) === secondNodes[$0] })
        var node = result
        var sharesNodes = false
        while let current = node {
            if (firstNodes + secondNodes).contains(where: { $0 === current }) { sharesNodes = true }
            node = current.next
        }
        #expect(result != nil && !sharesNodes, "the answer should be built from new nodes")
    }

    @Test("Handles numbers far beyond Int, in O(m + n)")
    func large() {
        let nines = Array(repeating: 9, count: 10_000)
        #expect(ForwardDigitListSum.add(ListNode.make([1]), ListNode.make(nines))?.values == [1] + Array(repeating: 0, count: 10_000))
        let ones = Array(repeating: 1, count: 10_000)
        let eights = Array(repeating: 8, count: 9_999)
        #expect(ForwardDigitListSum.add(ListNode.make(ones), ListNode.make(eights))?.values == [1] + Array(repeating: 9, count: 9_999))
    }
}
