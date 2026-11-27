import Testing
import DSAKit

@Suite struct ListNodeTests {
    @Test("make builds a list front to back, and values reads it back", arguments: [
        [1],
        [1, 2, 3],
        [5, 5, 5],
        [-3, 0, 3, 9],
    ])
    func roundTrip(values: [Int]) {
        #expect(ListNode.make(values)?.values == values)
        #expect(ListNode.make(values)?.count == values.count)
    }

    @Test("An empty array makes an empty list")
    func empty() {
        #expect(ListNode.make([]) == nil)
        #expect(ListNode.make([], loopingTo: nil) == nil)
    }

    @Test("init links a node to the next one")
    func initialiser() {
        let tail = ListNode(3)
        let head = ListNode(1, next: ListNode(2, next: tail))
        #expect(head.values == [1, 2, 3])
        #expect(head.next?.next === tail)
        #expect(tail.next == nil)
        head.next?.value = 20
        #expect(head.values == [1, 20, 3])
    }

    @Test("node(at:) walks forward, and returns nil past the end")
    func nodeAt() throws {
        let head = try #require(ListNode.make([10, 20, 30]))
        #expect(head.node(at: 0) === head)
        #expect(head.node(at: 2)?.value == 30)
        #expect(head.node(at: 3) == nil)
        #expect(head.node(at: -1) == nil)
    }

    @Test("make(_:loopingTo:) joins the last node back to the chosen node", arguments: [0, 2, 4])
    func cycle(index: Int) throws {
        let head = try #require(ListNode.make([1, 2, 3, 4, 5], loopingTo: index))
        let last = try #require(head.node(at: 4))
        #expect(last.next === head.node(at: index))
        #expect(head.node(at: 5) === head.node(at: index))
        last.next = nil
        #expect(head.values == [1, 2, 3, 4, 5])
    }

    @Test("A one-node cycle points at itself")
    func selfLoop() throws {
        let head = try #require(ListNode.make([7], loopingTo: 0))
        #expect(head.next === head)
        head.next = nil
    }

    @Test("make(_:loopingTo: nil) makes an ordinary list")
    func noLoop() {
        #expect(ListNode.make([1, 2, 3], loopingTo: nil)?.values == [1, 2, 3])
    }

    @Test("Walking a list with a cycle stops at the safety limit")
    func walkLimit() throws {
        let head = try #require(ListNode.make([1, 2], loopingTo: 0))
        #expect(head.values.count == ListNode.walkLimit)
        #expect(head.count == ListNode.walkLimit)
        #expect(head.description.hasSuffix("-> ..."))
        head.next?.next = nil
    }

    @Test("description draws the arrows")
    func description() throws {
        #expect(ListNode.make([1, 2, 3])!.description == "1 -> 2 -> 3 -> nil")
        #expect(ListNode(9).description == "9 -> nil")
        let long = try #require(ListNode.make(Array(1...60)))
        #expect(long.description.hasPrefix("1 -> 2 -> "))
        #expect(long.description.hasSuffix("49 -> 50 -> ..."))
    }

    @Test("Handles 100,000 nodes")
    func large() {
        let values = Array(0..<100_000)
        let head = ListNode.make(values)
        #expect(head?.values == values)
        #expect(head?.node(at: 99_999)?.value == 99_999)
    }
}
