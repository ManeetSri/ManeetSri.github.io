import Testing
import DSAKit
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// The identities of every node in a list, front to back.
private func identities(_ head: ListNode?) -> [ObjectIdentifier] {
    var result: [ObjectIdentifier] = []
    var current = head
    while let node = current, result.count <= 200_000 {
        result.append(ObjectIdentifier(node))
        current = node.next
    }
    return result
}

@Suite struct ReverseLinkedListTests {
    static let cases: [[Int]] = [
        [1, 2, 3, 4, 5],
        [1, 2],
        [7],
        [3, 3, 1],
        [-1, 0, 1, 0, -1, 9],
    ]

    @Test("The loop reverses the values", arguments: cases)
    func iterative(values: [Int]) {
        #expect(ReverseLinkedList.reversed(ListNode.make(values))?.values == values.reversed())
    }

    @Test("The recursion reverses the values", arguments: cases)
    func recursive(values: [Int]) {
        #expect(ReverseLinkedList.reversedRecursively(ListNode.make(values))?.values == values.reversed())
    }

    @Test("An empty list stays empty")
    func empty() {
        #expect(ReverseLinkedList.reversed(nil) == nil)
        #expect(ReverseLinkedList.reversedRecursively(nil) == nil)
    }

    @Test("Both reuse the original nodes, and the old head now ends the list")
    func reusesNodes() throws {
        for reverse in [ReverseLinkedList.reversed, ReverseLinkedList.reversedRecursively] {
            let head = try #require(ListNode.make([1, 2, 3, 4]))
            let before = identities(head)
            let result = reverse(head)
            #expect(identities(result) == before.reversed())
            #expect(head.next == nil, "the old head must point at nil, or the list has a cycle")
        }
    }

    @Test("Reversing twice gives back the original order")
    func twice() {
        let values = Array(1...50)
        let once = ReverseLinkedList.reversed(ListNode.make(values))
        #expect(ReverseLinkedList.reversed(once)?.values == values)
    }

    @Test("The loop handles 100,000 nodes")
    func largeIterative() {
        let values = Array(0..<100_000)
        #expect(ReverseLinkedList.reversed(ListNode.make(values))?.values == values.reversed())
    }

    @Test("The recursion handles 1,000 nodes")
    func largeRecursive() {
        let values = Array(0..<1_000)
        #expect(ReverseLinkedList.reversedRecursively(ListNode.make(values))?.values == values.reversed())
    }
}
