import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

private typealias Heap = DaryHeapLayout.DaryMinHeap

/// The same rules, written as free functions on an array, for comparing layouts step by step.
private struct ReferenceHeap {
    let d: Int
    var items: [Int] = []

    init(d: Int, items: [Int] = []) {
        self.d = d
        self.items = items
        if items.count >= 2 {
            var index = (items.count - 2) / d
            while index >= 0 {
                siftDown(index)
                index -= 1
            }
        }
    }

    mutating func push(_ value: Int) {
        items.append(value)
        var child = items.count - 1
        while child > 0 && items[child] < items[(child - 1) / d] {
            items.swapAt(child, (child - 1) / d)
            child = (child - 1) / d
        }
    }

    mutating func pop() -> Int? {
        guard !items.isEmpty else { return nil }
        items.swapAt(0, items.count - 1)
        let top = items.removeLast()
        siftDown(0)
        return top
    }

    mutating func siftDown(_ start: Int) {
        var node = start
        while d * node + 1 < items.count {
            let children = (d * node + 1)...min(d * node + d, items.count - 1)
            let smallest = children.reduce(children.lowerBound) { items[$1] < items[$0] ? $1 : $0 }
            if items[smallest] >= items[node] { return }
            items.swapAt(node, smallest)
            node = smallest
        }
    }
}

private struct Dice {
    var state: UInt64
    mutating func roll(_ bound: Int) -> Int {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return Int(state >> 33) % bound
    }
}

@Suite struct DaryHeapLayoutTests {
    @Test("The examples")
    func examples() {
        var heap = Heap(arity: 3)
        for value in [9, 7, 8, 6] { heap.push(value) }
        #expect(heap.storage == [6, 9, 8, 7])
        heap.push(5)
        #expect(heap.storage == [5, 6, 8, 7, 9])
        #expect(heap.pop() == 5)
        #expect(heap.storage == [6, 9, 8, 7])
        #expect(heap.peek() == 6 && heap.count == 4)

        let built = Heap(arity: 4, items: [9, 3, 7, 1, 8, 2])
        #expect(built.storage == [1, 2, 7, 9, 8, 3])

        var empty = Heap(arity: 2)
        #expect(empty.pop() == nil)
        #expect(empty.peek() == nil)
        #expect(empty.storage == [])
        #expect(empty.count == 0)
    }

    @Test("Ties go to the leftmost child, and only strictly smaller values move")
    func ties() {
        var heap = Heap(arity: 3, items: [5, 1, 1, 1])
        #expect(heap.storage == [1, 5, 1, 1])                  // the leftmost 1 rises
        #expect(heap.pop() == 1)
        #expect(heap.storage == [1, 5, 1])                     // 1 moved to the root; the leftmost 1 child wins
        heap.push(1)
        #expect(heap.storage == [1, 5, 1, 1])                  // an equal value doesn't climb
        let same = Heap(arity: 2, items: [4, 4, 4])
        #expect(same.storage == [4, 4, 4])
    }

    @Test("Small and single-item builds")
    func smallBuilds() {
        #expect(Heap(arity: 5, items: []).storage == [])
        #expect(Heap(arity: 5, items: [42]).storage == [42])
        #expect(Heap(arity: 5, items: [2, 1]).storage == [1, 2])
        #expect(Heap(arity: 16, items: Array((0..<17).reversed())).storage == ReferenceHeap(d: 16, items: Array((0..<17).reversed())).items)
    }

    @Test("Random operations match the reference layout exactly", arguments: [2, 3, 4, 7, 16])
    func randomOperations(arity: Int) {
        var dice = Dice(state: UInt64(46 + arity))
        var failures: [String] = []
        for round in 0..<30 {
            let start = (0..<dice.roll(40)).map { _ in dice.roll(round % 2 == 0 ? 6 : 1_000) }
            var heap = Heap(arity: arity, items: start)
            var reference = ReferenceHeap(d: arity, items: start)
            if heap.storage != reference.items { failures.append("building from \(start): \(heap.storage), expected \(reference.items)") }
            for _ in 0..<200 {
                if dice.roll(3) < 2 {
                    let value = dice.roll(round % 2 == 0 ? 6 : 1_000)
                    heap.push(value)
                    reference.push(value)
                } else if heap.pop() != reference.pop() {
                    failures.append("pop gave the wrong value")
                }
                if heap.storage != reference.items || heap.count != reference.items.count || heap.peek() != reference.items.first {
                    failures.append("storage \(heap.storage), expected \(reference.items)")
                }
                if failures.count >= 3 { break }
            }
            if failures.count >= 3 { break }
        }
        #expect(failures.isEmpty, "\(failures.prefix(3))")
    }

    @Test("Copies are independent")
    func copies() {
        var first = Heap(arity: 3, items: [5, 2, 8])
        var second = first
        second.push(1)
        _ = first.pop()
        #expect(first.storage == [5, 8])
        #expect(second.storage == [1, 5, 8, 2])
    }

    @Test("100,000 items: a fast build, then sorted pops", arguments: [2, 4, 9])
    func large(arity: Int) {
        let n = 100_000
        let items = (0..<n).map { ($0 * 7_919) % n }
        var heap = Heap(arity: arity, items: items)
        #expect(heap.storage == ReferenceHeap(d: arity, items: items).items)
        var wrong = 0
        for expected in 0..<1_000 where heap.pop() != expected { wrong += 1 }
        for value in stride(from: 999, through: 0, by: -1) { heap.push(value) }
        for expected in 0..<n where heap.pop() != expected { wrong += 1 }
        #expect(wrong == 0)
        #expect(heap.count == 0)
    }
}
