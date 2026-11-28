import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct PathCopyingListTests {
    typealias Node = PathCopyingList.Node

    /// A tiny deterministic generator, so the version history is the same every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    private func make(_ values: [Int]) -> Node? {
        var head: Node? = nil
        for value in values.reversed() {
            head = Node(value, next: head)
        }
        return head
    }

    private func values(_ head: Node?) -> [Int] {
        var result: [Int] = []
        var current = head
        while let node = current, result.count < 100_000 {
            result.append(node.value)
            current = node.next
        }
        return result
    }

    private func node(_ head: Node?, at index: Int) -> Node? {
        var current = head
        for _ in 0..<index {
            current = current?.next
        }
        return current
    }

    @Test("Inserts at any position", arguments: [
        ([1, 2, 3, 4], 9, 2, [1, 2, 9, 3, 4]),
        ([1, 2, 3, 4], 0, 0, [0, 1, 2, 3, 4]),
        ([1, 2, 3, 4], 5, 4, [1, 2, 3, 4, 5]),
        ([Int](), 7, 0, [7]),
        ([8], 8, 1, [8, 8]),
    ])
    func inserts(old: [Int], value: Int, index: Int, expected: [Int]) {
        let head = make(old)
        #expect(values(PathCopyingList.inserting(value, at: index, into: head)) == expected)
        #expect(values(head) == old, "the old version must not change")
    }

    @Test("Removes at any position", arguments: [
        ([1, 2, 3, 4], 1, [1, 3, 4]),
        ([1, 2, 3, 4], 0, [2, 3, 4]),
        ([1, 2, 3, 4], 3, [1, 2, 3]),
        ([7], 0, [Int]()),
    ])
    func removes(old: [Int], index: Int, expected: [Int]) {
        let head = make(old)
        #expect(values(PathCopyingList.removing(at: index, from: head)) == expected)
        #expect(values(head) == old, "the old version must not change")
    }

    @Test("Edits at the front copy nothing")
    func frontEdits() throws {
        let head = try #require(make([1, 2, 3]))
        let inserted = PathCopyingList.inserting(0, at: 0, into: head)
        #expect(inserted?.next === head)
        let removed = PathCopyingList.removing(at: 0, from: head)
        #expect(removed === head.next)
    }

    @Test("Shares every node after the change, for every length and index up to 8")
    func sharing() {
        var failures: [String] = []
        for length in 0...8 {
            let old = (0..<length).map { ($0 + 1) * 10 }
            let head = make(old)
            for index in 0...length {
                let new = PathCopyingList.inserting(-1, at: index, into: head)
                var expected = old
                expected.insert(-1, at: index)
                let shared = (index..<length).allSatisfy { node(new, at: $0 + 1) === node(head, at: $0) }
                if values(new) != expected || !shared || values(head) != old {
                    failures.append("inserting at \(index) into \(length) nodes")
                }
            }
            for index in 0..<length {
                let new = PathCopyingList.removing(at: index, from: head)
                var expected = old
                expected.remove(at: index)
                let shared = ((index + 1)..<length).allSatisfy { node(new, at: $0 - 1) === node(head, at: $0) }
                if values(new) != expected || !shared || values(head) != old {
                    failures.append("removing at \(index) from \(length) nodes")
                }
            }
        }
        #expect(failures.isEmpty, "\(failures)")
    }

    @Test("Every version in a long history stays valid")
    func history() {
        var steps = Steps(seed: 25)
        var versions: [Node?] = [nil]
        var expected: [[Int]] = [[]]
        for step in 0..<300 {
            let from = steps.next(below: versions.count)
            var model = expected[from]
            let new: Node?
            if model.isEmpty || steps.next(below: 3) > 0 {
                let index = steps.next(below: model.count + 1)
                new = PathCopyingList.inserting(step, at: index, into: versions[from])
                model.insert(step, at: index)
            } else {
                let index = steps.next(below: model.count)
                new = PathCopyingList.removing(at: index, from: versions[from])
                model.remove(at: index)
            }
            versions.append(new)
            expected.append(model)
        }
        let mismatches = zip(versions, expected).filter { values($0) != $1 }.count
        #expect(mismatches == 0)
    }

    @Test("Edits near the front of a 5,000-node list stay cheap")
    func large() {
        let base = make(Array(0..<5_000))
        let shareFrom = node(base, at: 3)
        var allShare = shareFrom != nil
        var lastInsert: Node? = nil
        var lastRemove: Node? = nil
        for value in 0..<1_000 {
            lastInsert = PathCopyingList.inserting(-value, at: 3, into: base)
            lastRemove = PathCopyingList.removing(at: 2, from: base)
            if node(lastInsert, at: 4) !== shareFrom || node(lastRemove, at: 2) !== shareFrom { allShare = false }
        }
        #expect(allShare)
        #expect(values(lastInsert) == [0, 1, 2, -999] + Array(3..<5_000))
        #expect(values(lastRemove) == [0, 1] + Array(3..<5_000))
        #expect(values(base) == Array(0..<5_000))
    }
}
