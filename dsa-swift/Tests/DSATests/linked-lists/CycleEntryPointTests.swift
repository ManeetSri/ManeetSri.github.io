import Testing
import DSAKit
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct CycleEntryPointTests {
    @Test("Finds the node the last node loops back to", arguments: [
        ([1, 2, 3, 4, 5, 6], 2),
        ([1, 2, 3, 4, 5, 6], 0),
        ([1, 2, 3, 4, 5, 6], 5),
        ([1, 2], 0),
        ([1, 2], 1),
        ([9], 0),
        ([4, 4, 4, 4], 1),
        (Array(1...11), 3),
        (Array(1...12), 7),
    ])
    func findsEntry(values: [Int], loopTo: Int) throws {
        let head = try #require(ListNode.make(values, loopingTo: loopTo))
        let expected = head.node(at: loopTo)
        let last = head.node(at: values.count - 1)
        #expect(CycleEntryPoint.hasCycle(head))
        #expect(CycleEntryPoint.entry(head) === expected)
        #expect(last?.next === expected, "the list must not be changed")
        last?.next = nil
        #expect(head.values == values, "the list must not be changed")
    }

    @Test("Lists that end have no cycle", arguments: [
        [Int](),
        [1],
        [1, 2],
        [1, 2, 3],
        Array(1...10),
    ])
    func noCycle(values: [Int]) {
        let head = ListNode.make(values)
        #expect(!CycleEntryPoint.hasCycle(head))
        #expect(CycleEntryPoint.entry(head) == nil)
        #expect(head?.values ?? [] == values, "the list must not be changed")
    }

    @Test("Every loop position in lists of up to 9 nodes")
    func everyPosition() throws {
        for length in 1...9 {
            for loopTo in 0..<length {
                let values = Array(0..<length)
                let head = try #require(ListNode.make(values, loopingTo: loopTo))
                let found = CycleEntryPoint.entry(head)
                head.node(at: length - 1)?.next = nil
                #expect(found === head.node(at: loopTo), "length \(length), loop to \(loopTo)")
            }
        }
    }

    @Test("Stays fast on 100,000 nodes", arguments: [0, 1, 50_000, 99_998, 99_999])
    func large(loopTo: Int) throws {
        let values = Array(0..<100_000)
        let head = try #require(ListNode.make(values, loopingTo: loopTo))
        let expected = head.node(at: loopTo)
        #expect(CycleEntryPoint.hasCycle(head))
        #expect(CycleEntryPoint.entry(head) === expected)
        head.node(at: 99_999)?.next = nil
        #expect(!CycleEntryPoint.hasCycle(head))
        #expect(CycleEntryPoint.entry(head) == nil)
    }
}
