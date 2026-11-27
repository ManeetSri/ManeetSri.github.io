import Testing
import DSAKit
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct InsertAfterMarkersTests {
    @Test("Inserts after every marker", arguments: [
        ([1, 2, 3, 2], 2, 9, [1, 2, 9, 3, 2, 9]),
        ([4], 4, 7, [4, 7]),
        ([5, 5], 5, 5, [5, 5, 5, 5]),
        ([1, 3], 2, 0, [1, 3]),
        ([2, 1], 2, 2, [2, 2, 1]),
        ([1, 2, 2, 1], 1, -1, [1, -1, 2, 2, 1, -1]),
        ([-3, 0, -3], -3, 0, [-3, 0, 0, -3, 0]),
    ])
    func inserts(values: [Int], marker: Int, value: Int, expected: [Int]) {
        let head = ListNode.make(values)
        InsertAfterMarkers.insert(value, afterEvery: marker, in: head)
        #expect(head?.values == expected)
    }

    @Test("An empty list stays empty")
    func empty() {
        InsertAfterMarkers.insert(1, afterEvery: 1, in: nil)
        #expect(Bool(true))
    }

    @Test("Keeps the original nodes, in order, with new nodes between them")
    func keepsOriginalNodes() throws {
        let values = [7, 1, 7, 7, 2]
        let head = try #require(ListNode.make(values))
        let originals = (0..<values.count).map { head.node(at: $0)! }
        InsertAfterMarkers.insert(0, afterEvery: 7, in: head)
        #expect(head.values == [7, 0, 1, 7, 0, 7, 0, 2])
        let positions = [0, 2, 3, 5, 7]           // where the original nodes should now be
        #expect(zip(positions, originals).allSatisfy { head.node(at: $0) === $1 })
        let added = [1, 4, 6].compactMap { head.node(at: $0) }
        #expect(added.count == 3 && added.allSatisfy { node in !originals.contains { $0 === node } })
    }

    @Test("Stays O(n) on 20,000 nodes")
    func large() {
        let everyMarker = ListNode.make(Array(repeating: 3, count: 20_000))
        InsertAfterMarkers.insert(3, afterEvery: 3, in: everyMarker)
        #expect(everyMarker?.count == 40_000)
        #expect(everyMarker?.values.allSatisfy { $0 == 3 } == true)

        let values = Array(0..<20_000)
        let head = ListNode.make(values)
        InsertAfterMarkers.insert(-1, afterEvery: 19_999, in: head)
        #expect(head?.values == values + [-1])
    }
}
