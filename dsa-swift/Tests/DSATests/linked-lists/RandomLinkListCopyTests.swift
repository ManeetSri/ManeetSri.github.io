import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct RandomLinkListCopyTests {
    typealias Node = RandomLinkListCopy.Node

    /// A tiny deterministic generator, so the random cases are the same every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    /// Builds a list whose node i holds values[i] and has its random link at randoms[i].
    private func makeList(_ values: [Int], randoms: [Int?]) -> Node? {
        let nodes = values.map { Node($0) }
        for index in nodes.indices {
            if index + 1 < nodes.count { nodes[index].next = nodes[index + 1] }
            if let target = randoms[index] { nodes[index].random = nodes[target] }
        }
        return nodes.first
    }

    /// The nodes from `head` on, at most `limit` of them so a broken copy can't loop forever.
    private func nodes(from head: Node?, limit: Int = 20_000) -> [Node] {
        var result: [Node] = []
        var current = head
        while let node = current, result.count < limit {
            result.append(node)
            current = node.next
        }
        return result
    }

    /// The list's values and the index of each random target (-1 for a target outside the list).
    private func shape(_ head: Node?) -> (values: [Int], randoms: [Int?]) {
        let list = nodes(from: head)
        let index = Dictionary(list.enumerated().map { (ObjectIdentifier($0.element), $0.offset) }, uniquingKeysWith: { first, _ in first })
        let randoms = list.map { node in node.random.map { index[ObjectIdentifier($0)] ?? -1 } }
        return (list.map(\.value), randoms)
    }

    private func checkCopy(values: [Int], randoms: [Int?]) -> Bool {
        let original = makeList(values, randoms: randoms)
        let originalNodes = nodes(from: original)
        let copy = RandomLinkListCopy.deepCopy(original)
        let copied = shape(copy)
        let after = shape(original)
        let copyNodes = nodes(from: copy)
        let originalIDs = Set(originalNodes.map { ObjectIdentifier($0) })
        let independent = copyNodes.allSatisfy { node in
            !originalIDs.contains(ObjectIdentifier(node)) && !(node.random.map { originalIDs.contains(ObjectIdentifier($0)) } ?? false)
        }
        let originalIntact = after.values == values && after.randoms == randoms &&
            zip(nodes(from: original), originalNodes).allSatisfy { $0 === $1 }
        return copied.values == values && copied.randoms == randoms && independent && originalIntact
    }

    @Test("Copies values, next links and random links", arguments: [
        ([3, 8, 5, 8], [2, 0, nil, 1] as [Int?]),
        ([6], [0]),
        ([1, 2], [nil, nil]),
        ([7, 7, 7], [2, 2, 0]),
        ([4, 9, 4, 9, 4], [4, 3, 2, 1, 0]),
        ([-5, 0], [1, 1]),
    ])
    func copies(values: [Int], randoms: [Int?]) {
        #expect(checkCopy(values: values, randoms: randoms))
    }

    @Test("An empty list copies to nil")
    func empty() {
        #expect(RandomLinkListCopy.deepCopy(nil) == nil)
    }

    @Test("The copy shares no nodes with the original, and outlives it")
    func independent() throws {
        var original = makeList([1, 2, 3], randoms: [2, nil, 0])
        let copy = try #require(RandomLinkListCopy.deepCopy(original))
        original?.value = 100
        original?.next?.random = original
        original = nil                                 // free the original list
        #expect(shape(copy).values == [1, 2, 3])
        #expect(shape(copy).randoms == [2, nil, 0])
    }

    @Test("Random lists copy correctly")
    func randomLists() {
        var steps = Steps(seed: 138)
        var failures = 0
        for _ in 0..<200 {
            let length = 1 + steps.next(below: 15)
            let values = (0..<length).map { _ in steps.next(below: 4) }
            let randoms: [Int?] = (0..<length).map { _ in steps.next(below: 4) == 0 ? nil : steps.next(below: length) }
            if !checkCopy(values: values, randoms: randoms) { failures += 1 }
        }
        #expect(failures == 0)
    }

    @Test("Stays O(n) on 10,000 nodes")
    func large() {
        var steps = Steps(seed: 10_000)
        let values = Array(0..<10_000).map { $0 % 100 }
        let randoms: [Int?] = (0..<10_000).map { _ in steps.next(below: 10) == 0 ? nil : steps.next(below: 10_000) }
        #expect(checkCopy(values: values, randoms: randoms))
    }
}
