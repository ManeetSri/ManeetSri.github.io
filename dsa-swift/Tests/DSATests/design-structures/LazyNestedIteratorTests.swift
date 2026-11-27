import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct LazyNestedIteratorTests {
    typealias Item = LazyNestedIterator.Item
    typealias Flattener = LazyNestedIterator.Flattener

    /// A tiny deterministic generator, so the random tests do the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    /// The numbers in order, found the straightforward recursive way.
    private func flattened(_ items: [Item]) -> [Int] {
        var result: [Int] = []
        for item in items {
            switch item {
            case .number(let value): result.append(value)
            case .list(let inner): result += flattened(inner)
            }
        }
        return result
    }

    private func randomItems(_ steps: inout Steps, depth: Int) -> [Item] {
        var items: [Item] = []
        for _ in 0..<steps.next(below: 5) {
            if depth > 0 && steps.next(below: 3) == 0 {
                items.append(.list(randomItems(&steps, depth: depth - 1)))
            } else {
                items.append(.number(steps.next(below: 100) - 50))
            }
        }
        return items
    }

    @Test("Numbers come out left to right, at any depth")
    func examples() {
        let cases: [([Item], [Int])] = [
            ([.number(1), .list([.number(2), .list([.number(3), .list([])]), .number(4)]), .list([]), .number(5)], [1, 2, 3, 4, 5]),
            ([], []),
            ([.list([]), .list([.list([])]), .list([.list([.list([])])])], []),
            ([.list([.list([.list([.number(7)])])])], [7]),
            ([.number(-1), .number(0), .list([.number(-1)])], [-1, 0, -1]),
            ([.list([.number(1), .number(2)]), .list([.number(3)]), .number(4)], [1, 2, 3, 4]),
        ]
        for (items, expected) in cases {
            var iterator = Flattener(items)
            var found: [Int] = []
            while let value = iterator.next(), found.count <= expected.count {
                found.append(value)
            }
            #expect(found == expected)
        }
    }

    @Test("peek looks ahead without consuming, as often as you like")
    func peekRepeats() {
        var iterator = Flattener([.list([]), .number(4), .list([.list([.number(5)])]), .list([])])
        #expect(iterator.peek() == 4)
        #expect(iterator.peek() == 4)
        #expect(iterator.next() == 4)
        #expect(iterator.peek() == 5)
        #expect(iterator.next() == 5)
        #expect(iterator.peek() == nil)
        #expect(iterator.next() == nil)
        #expect(iterator.next() == nil)
        #expect(iterator.peek() == nil)
    }

    @Test("Works with for-in and Sequence methods")
    func sequenceConformance() {
        let items: [Item] = [.number(3), .list([.number(1), .list([.number(4)])]), .number(1), .list([.number(5)])]
        #expect(Array(Flattener(items)) == [3, 1, 4, 1, 5])
        #expect(Flattener(items).reduce(0, +) == 14)
        #expect(Array(Flattener(items).prefix(2)) == [3, 1])
        var total = 0
        for value in Flattener(items) {
            total += value
        }
        #expect(total == 14)
    }

    @Test("Random nested lists match a recursive flatten, with peeks mixed in", arguments: [1, 2, 3])
    func matchesModel(seed: Int) {
        var steps = Steps(seed: UInt64(seed) &* 977)
        for round in 0..<300 {
            let items = randomItems(&steps, depth: 1 + round % 6)
            let expected = flattened(items)
            var iterator = Flattener(items)
            var position = 0
            var correct = true
            while position <= expected.count {
                let wanted = position < expected.count ? expected[position] : nil
                if steps.next(below: 3) == 0 {
                    if iterator.peek() != wanted { correct = false; break }
                }
                if iterator.next() != wanted { correct = false; break }
                position += 1
            }
            if !correct {
                Issue.record("wrong numbers for \(items)")
                return
            }
        }
    }

    @Test("Deep nesting: 500 lists inside each other")
    func deepNesting() {
        var items: [Item] = [.number(0)]
        for depth in 1..<500 {
            items = [.number(depth), .list(items)]
        }
        var iterator = Flattener(items)
        var found: [Int] = []
        while let value = iterator.next(), found.count < 500 {
            found.append(value)
        }
        #expect(found == Array((0..<500).reversed()))
    }

    @Test("Thousands of empty lists are skipped")
    func emptyLists() {
        let items: [Item] = Array(repeating: .list([]), count: 100_000) + [.number(1)]
            + Array(repeating: .list([.list([])]), count: 50_000) + [.number(2)] + Array(repeating: .list([]), count: 10)
        var iterator = Flattener(items)
        #expect(iterator.peek() == 1)
        #expect(iterator.next() == 1)
        #expect(iterator.next() == 2)
        #expect(iterator.peek() == nil)
        #expect(iterator.next() == nil)
    }

    @Test("Creating an iterator does no work up front", .timeLimit(.minutes(1)))
    func lazyStart() {
        let block: [Item] = (0..<200).map { .number($0) }
        let items: [Item] = (0..<1_000).map { _ in .list(block) }     // 200,000 numbers
        var correct = true
        for _ in 0..<2_000 {
            var iterator = Flattener(items)
            if iterator.next() != 0 || iterator.peek() != 1 || iterator.next() != 1 {
                correct = false
            }
        }
        #expect(correct, "taking the first two numbers shouldn't flatten all 200,000")
    }

    @Test("A full pass over 300,000 numbers is linear")
    func large() {
        var items: [Item] = []
        for group in 0..<1_000 {
            let inner: [Item] = (0..<100).map { .number(group * 300 + $0) }
            items.append(.list([.list(inner), .number(group * 300 + 100)]))
            items.append(contentsOf: (101..<300).map { .number(group * 300 + $0) })
        }
        var iterator = Flattener(items)
        var expectedNext = 0
        var correct = true
        while let value = iterator.next() {
            if value != expectedNext || (value % 1_000 == 0 && iterator.peek() != (value + 1 < 300_000 ? value + 1 : nil)) {
                correct = false
                break
            }
            expectedNext += 1
        }
        #expect(correct)
        #expect(expectedNext == 300_000)
    }
}
