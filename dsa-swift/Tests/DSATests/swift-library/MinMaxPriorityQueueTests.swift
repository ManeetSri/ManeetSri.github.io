import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct MinMaxRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct MinMaxPriorityQueueTests {
    @Test("The examples")
    func examples() {
        var queue = MinMaxPriorityQueue.Queue<Int>()
        for value in [5, 1, 9, 3] {
            queue.insert(value)
        }
        #expect(queue.min == 1 && queue.max == 9 && queue.count == 4)
        #expect(queue.popMax() == 9)
        #expect(queue.popMax() == 5)
        #expect(queue.popMin() == 1)
        #expect(queue.min == 3 && queue.max == 3)

        var built = MinMaxPriorityQueue.Queue([4, 4, 2, 8, 8])
        #expect(built.popMin() == 2)
        #expect(built.popMax() == 8)
        #expect(built.popMax() == 8)
        #expect(built.count == 2)

        var words = MinMaxPriorityQueue.Queue<String>()
        for word in ["pear", "fig", "plum"] {
            words.insert(word)
        }
        #expect(words.popMin() == "fig")
        #expect(words.popMax() == "plum")

        var empty = MinMaxPriorityQueue.Queue<Int>()
        #expect(empty.popMin() == nil && empty.popMax() == nil)
        #expect(empty.min == nil && empty.max == nil && empty.isEmpty && empty.count == 0)
    }

    @Test("Draining from both ends gives sorted order")
    func drains() {
        var random = MinMaxRandom(seed: 69)
        let values = (0..<500).map { _ in Int.random(in: -50...50, using: &random) }
        var low = MinMaxPriorityQueue.Queue(values)
        var drainedLow: [Int] = []
        while let value = low.popMin() {
            drainedLow.append(value)
            if drainedLow.count > values.count { break }
        }
        #expect(drainedLow == values.sorted())
        var high = MinMaxPriorityQueue.Queue<Int>()
        for value in values {
            high.insert(value)
        }
        var drainedHigh: [Int] = []
        while let value = high.popMax() {
            drainedHigh.append(value)
            if drainedHigh.count > values.count { break }
        }
        #expect(drainedHigh == values.sorted(by: >))
    }

    @Test("Random operations match a sorted array", arguments: [1, 2, 3, 4])
    func matchesSortedArray(seed: UInt64) {
        var random = MinMaxRandom(seed: seed)
        let initial = (0..<Int.random(in: 0...20, using: &random)).map { _ in Int.random(in: 0...30, using: &random) }
        var queue = MinMaxPriorityQueue.Queue(initial)
        var reference = initial.sorted()
        for step in 0..<4_000 {
            switch Int.random(in: 0..<5, using: &random) {
            case 0, 1:
                let value = Int.random(in: 0...30, using: &random)
                queue.insert(value)
                reference.insert(value, at: reference.firstIndex { $0 >= value } ?? reference.count)
            case 2:
                #expect(queue.popMin() == (reference.isEmpty ? nil : reference.removeFirst()), "step \(step): popMin")
            case 3:
                #expect(queue.popMax() == reference.popLast(), "step \(step): popMax")
            default:
                #expect(queue.min == reference.first && queue.max == reference.last, "step \(step): peek")
            }
            #expect(queue.count == reference.count)
            if queue.count != reference.count { return }
        }
    }

    @Test("Copies are independent")
    func copies() {
        var original = MinMaxPriorityQueue.Queue([3, 1, 2])
        var copy = original
        #expect(copy.popMax() == 3)
        copy.insert(10)
        #expect(original.max == 3 && original.count == 3)
        #expect(copy.max == 10 && copy.count == 3)
        #expect(original.popMin() == 1)
    }

    @Test("200,000 operations, alternating ends")
    func large() {
        var random = MinMaxRandom(seed: 200_000)
        var queue = MinMaxPriorityQueue.Queue<Int>()
        var inserted: [Int] = []
        for _ in 0..<100_000 {
            let value = Int.random(in: 0...1_000_000_000, using: &random)
            queue.insert(value)
            inserted.append(value)
        }
        #expect(queue.count == 100_000)
        let sorted = inserted.sorted()
        #expect(queue.min == sorted.first && queue.max == sorted.last)
        var lows: [Int] = []
        var highs: [Int] = []
        for i in 0..<50_000 {
            if i.isMultiple(of: 2) {
                if let value = queue.popMin() { lows.append(value) }
            } else {
                if let value = queue.popMax() { highs.append(value) }
            }
        }
        #expect(lows == Array(sorted.prefix(25_000)))
        #expect(highs == Array(sorted.suffix(25_000).reversed()))
        #expect(queue.count == 50_000)
        #expect(queue.min == sorted[25_000] && queue.max == sorted[74_999])
        // An O(n) build from a large array
        let built = MinMaxPriorityQueue.Queue(inserted)
        #expect(built.count == 100_000 && built.min == sorted.first && built.max == sorted.last)
    }
}
