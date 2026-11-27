import Testing
import DSAKit
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct UnitsFirstListSumTests {
    /// The digits of a non-negative Int, units first.
    private func digits(_ number: Int) -> [Int] {
        var result: [Int] = []
        var rest = number
        repeat {
            result.append(rest % 10)
            rest /= 10
        } while rest > 0
        return result
    }

    @Test("Adds digit by digit", arguments: [
        ([2, 4, 3], [5, 6, 4], [7, 0, 8]),
        ([9, 9], [1], [0, 0, 1]),
        ([5], [5], [0, 1]),
        ([1, 8], [0], [1, 8]),
        ([0], [0], [0]),
        ([9, 9, 9, 9], [2, 1], [1, 1, 0, 0, 1]),
        ([1], [9, 9, 9], [0, 0, 0, 1]),
    ])
    func adds(first: [Int], second: [Int], expected: [Int]) {
        #expect(UnitsFirstListSum.add(ListNode.make(first), ListNode.make(second))?.values == expected)
    }

    @Test("Agrees with Int addition")
    func matchesInts() {
        var mismatches = 0
        for x in stride(from: 0, through: 2_000, by: 37) {
            for y in [0, 1, 9, 99, 100, 512, 999, 1_001, 98_765] {
                if UnitsFirstListSum.add(ListNode.make(digits(x)), ListNode.make(digits(y)))?.values != digits(x + y) {
                    mismatches += 1
                }
            }
        }
        #expect(mismatches == 0)
    }

    @Test("Leaves both inputs exactly as they were")
    func inputsUnchanged() throws {
        let first = try #require(ListNode.make([9, 9, 9]))
        let second = try #require(ListNode.make([1]))
        let firstNodes = (0..<3).map { first.node(at: $0)! }
        let result = UnitsFirstListSum.add(first, second)
        #expect(result?.values == [0, 0, 0, 1])
        #expect(first.values == [9, 9, 9] && second.values == [1])
        #expect((0..<3).allSatisfy { first.node(at: $0) === firstNodes[$0] })
        var node = result
        var sharesNodes = false
        while let current = node {
            if current === second || firstNodes.contains(where: { $0 === current }) { sharesNodes = true }
            node = current.next
        }
        #expect(result != nil && !sharesNodes, "the answer should be built from new nodes")
    }

    @Test("Handles numbers far beyond Int")
    func large() {
        let nines = Array(repeating: 9, count: 10_000)
        #expect(UnitsFirstListSum.add(ListNode.make(nines), ListNode.make([1]))?.values == Array(repeating: 0, count: 10_000) + [1])
        let ones = Array(repeating: 1, count: 10_000)
        let eights = Array(repeating: 8, count: 9_999)
        #expect(UnitsFirstListSum.add(ListNode.make(ones), ListNode.make(eights))?.values == Array(repeating: 9, count: 9_999) + [1])
    }
}
