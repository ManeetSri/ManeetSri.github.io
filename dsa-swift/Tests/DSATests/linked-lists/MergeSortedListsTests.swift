import Testing
import DSAKit
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct MergeSortedListsTests {
    @Test("Merges into one sorted list", arguments: [
        ([1, 4, 6], [2, 3, 7, 8], [1, 2, 3, 4, 6, 7, 8]),
        ([1, 2, 3], [4, 5, 6], [1, 2, 3, 4, 5, 6]),
        ([4, 5, 6], [1, 2, 3], [1, 2, 3, 4, 5, 6]),
        ([2, 2, 5], [2, 5, 5], [2, 2, 2, 5, 5, 5]),
        ([-5, 0], [-7, -5, 10], [-7, -5, -5, 0, 10]),
        ([3], [3], [3, 3]),
    ])
    func merges(first: [Int], second: [Int], expected: [Int]) {
        #expect(MergeSortedLists.merged(ListNode.make(first), ListNode.make(second))?.values == expected)
    }

    @Test("An empty list on either side")
    func empties() {
        #expect(MergeSortedLists.merged(nil, nil) == nil)
        #expect(MergeSortedLists.merged(ListNode.make([1, 2]), nil)?.values == [1, 2])
        #expect(MergeSortedLists.merged(nil, ListNode.make([3]))?.values == [3])
    }

    @Test("Reuses the nodes, taking from the first list on ties")
    func reusesNodes() throws {
        let first = try #require(ListNode.make([1, 3, 3]))
        let second = try #require(ListNode.make([3, 4]))
        let expectedOrder = [first, first.next!, first.next!.next!, second, second.next!]
        let result = MergeSortedLists.merged(first, second)
        let actual = (0..<5).compactMap { result?.node(at: $0) }
        #expect(actual.count == 5 && zip(actual, expectedOrder).allSatisfy { $0 === $1 })
        #expect(result?.node(at: 5) == nil)
    }

    @Test("Matches sorting the two lists together")
    func matchesSorting() {
        for seed in 0..<200 {
            let first = (0..<(seed % 6)).map { ($0 * 7 + seed) % 10 }.sorted()
            let second = (0..<(seed % 5)).map { ($0 * 3 + seed * 2) % 10 }.sorted()
            let result = MergeSortedLists.merged(ListNode.make(first), ListNode.make(second))
            #expect(result?.values ?? [] == (first + second).sorted(), "\(first) and \(second)")
        }
    }

    @Test("Handles two lists of 50,000 nodes without running out of stack")
    func large() {
        let evens = Array(stride(from: 0, to: 100_000, by: 2))
        let odds = Array(stride(from: 1, to: 100_000, by: 2))
        #expect(MergeSortedLists.merged(ListNode.make(evens), ListNode.make(odds))?.values == Array(0..<100_000))
        #expect(MergeSortedLists.merged(ListNode.make(odds), ListNode.make(evens))?.values == Array(0..<100_000))
    }
}
