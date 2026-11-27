import Testing
import DSAKit
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct MergeKSortedListsTests {
    /// The values of a merged list, unlinking it as it goes so a long list is freed without deep
    /// recursion. Stops after `limit` nodes in case a broken merge made a cycle.
    private func valuesAndRelease(_ head: ListNode?, limit: Int = 2_000_000) -> [Int] {
        var values: [Int] = []
        var current = head
        while let node = current, values.count < limit {
            values.append(node.value)
            current = node.next
            node.next = nil
        }
        return values
    }

    @Test("Merges a few lists", arguments: [
        ([[1, 4, 7], [2, 5, 8], [3, 6, 9]], [1, 2, 3, 4, 5, 6, 7, 8, 9]),
        ([[2, 6], [1, 3, 4, 10], [5]], [1, 2, 3, 4, 5, 6, 10]),
        ([[1, 1, 3], [1, 2], [3, 3]], [1, 1, 1, 2, 3, 3, 3]),
        ([[-5, 0, 5], [-10, 10]], [-10, -5, 0, 5, 10]),
        ([[4, 5, 6]], [4, 5, 6]),
        ([[9], [8], [7]], [7, 8, 9]),
    ])
    func merges(lists: [[Int]], expected: [Int]) {
        #expect(valuesAndRelease(MergeKSortedLists.merge(lists.map { ListNode.make($0) })) == expected)
    }

    @Test("Empty lists anywhere")
    func empties() {
        #expect(MergeKSortedLists.merge([]) == nil)
        #expect(MergeKSortedLists.merge([nil, nil]) == nil)
        let merged = MergeKSortedLists.merge([nil, ListNode.make([2, 3]), nil, ListNode.make([1]), nil])
        #expect(valuesAndRelease(merged) == [1, 2, 3])
    }

    @Test("Reuses the original nodes")
    func reusesNodes() {
        let lists = [ListNode.make([1, 5]), ListNode.make([2, 3, 9]), ListNode.make([4])]
        var originals = Set<ObjectIdentifier>()
        for head in lists {
            var current = head
            while let node = current {
                originals.insert(ObjectIdentifier(node))
                current = node.next
            }
        }
        var merged = Set<ObjectIdentifier>()
        var current = MergeKSortedLists.merge(lists)
        var steps = 0
        while let node = current, steps < 100 {
            merged.insert(ObjectIdentifier(node))
            current = node.next
            steps += 1
        }
        #expect(steps == 6)
        #expect(merged == originals)
    }

    @Test("10,000 lists of 10 nodes")
    func manyShortLists() {
        // List i holds i, 10,000 + i, 20,000 + i, …, so the merge is 0, 1, 2, … 99,999
        let lists = (0..<10_000).map { i in ListNode.make((0..<10).map { $0 * 10_000 + i }) }
        #expect(valuesAndRelease(MergeKSortedLists.merge(lists)) == Array(0..<100_000))
    }

    @Test("2,000 lists of 50 nodes with many duplicates")
    func duplicates() {
        let arrays = (0..<2_000).map { i in (0..<50).map { (i % 37) + $0 * 40 } }
        let expected = arrays.flatMap { $0 }.sorted()
        #expect(valuesAndRelease(MergeKSortedLists.merge(arrays.map { ListNode.make($0) })) == expected)
    }

    @Test("One long list among many single nodes")
    func lopsided() {
        let long = ListNode.make(Array(stride(from: 0, to: 100_000, by: 2)))
        let singles = (0..<1_000).map { ListNode.make([$0 * 100 + 1]) }
        let expected = (Array(stride(from: 0, to: 100_000, by: 2)) + (0..<1_000).map { $0 * 100 + 1 }).sorted()
        #expect(valuesAndRelease(MergeKSortedLists.merge([long] + singles)) == expected)
    }
}
