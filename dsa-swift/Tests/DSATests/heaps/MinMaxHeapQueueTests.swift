import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

private typealias Queue = MinMaxHeapQueue.BothEndsQueue

private struct Dice {
    var state: UInt64
    mutating func roll(_ bound: Int) -> Int {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return Int(state >> 33) % bound
    }
}

@Suite struct MinMaxHeapQueueTests {
    @Test("The examples")
    func examples() {
        var queue = Queue()
        for value in [5, 3, 8, 1, 9, 4] { queue.insert(value) }
        #expect(queue.min == 1)
        #expect(queue.max == 9)
        #expect(queue.count == 6)
        #expect(queue.popMin() == 1)
        #expect(queue.popMax() == 9)
        #expect(queue.min == 3)
        #expect(queue.max == 8)
        queue.insert(7)
        queue.insert(7)
        #expect(queue.popMax() == 8)
        #expect(queue.popMax() == 7)
        #expect(queue.max == 7)
        #expect(queue.count == 4)
    }

    @Test("Empty and single-value queues")
    func tiny() {
        var queue = Queue()
        #expect(queue.isEmpty)
        #expect(queue.popMin() == nil)
        #expect(queue.popMax() == nil)
        #expect(queue.min == nil && queue.max == nil)
        queue.insert(42)
        #expect(!queue.isEmpty)
        #expect(queue.min == 42 && queue.max == 42)
        #expect(queue.popMax() == 42)
        #expect(queue.isEmpty)
        queue.insert(-1)
        queue.insert(-2)
        #expect(queue.min == -2 && queue.max == -1)
        #expect(queue.popMin() == -2)
        #expect(queue.popMin() == -1)
        #expect(queue.popMin() == nil)
    }

    @Test("Popping one end empties the queue in order", arguments: [true, false])
    func drain(fromBottom: Bool) {
        var queue = Queue()
        let values = [15, 3, 9, 3, 27, -4, 0, 12, 9, 9, 100, -50, 8]
        for value in values { queue.insert(value) }
        var popped: [Int] = []
        while let value = fromBottom ? queue.popMin() : queue.popMax() { popped.append(value) }
        #expect(popped == (fromBottom ? values.sorted() : values.sorted(by: >)))
    }

    @Test("Copies are independent")
    func copies() {
        var first = Queue()
        for value in [4, 1, 7] { first.insert(value) }
        var second = first
        _ = second.popMin()
        second.insert(100)
        #expect(first.min == 1 && first.max == 7 && first.count == 3)
        #expect(second.min == 4 && second.max == 100 && second.count == 3)
    }

    @Test("Random operations match a sorted array")
    func randomOperations() {
        var dice = Dice(state: 42)
        var failures: [String] = []
        for round in 0..<60 {
            var queue = Queue()
            var sorted: [Int] = []
            for _ in 0..<300 {
                switch dice.roll(5) {
                case 0, 1:
                    let value = dice.roll(round % 2 == 0 ? 10 : 1_000) - 5
                    queue.insert(value)
                    sorted.insert(value, at: sorted.firstIndex { $0 >= value } ?? sorted.count)
                case 2:
                    let expected = sorted.isEmpty ? nil : sorted.removeFirst()
                    let actual = queue.popMin()
                    if actual != expected { failures.append("popMin gave \(String(describing: actual)), expected \(String(describing: expected))") }
                case 3:
                    let expected = sorted.popLast()
                    let actual = queue.popMax()
                    if actual != expected { failures.append("popMax gave \(String(describing: actual)), expected \(String(describing: expected))") }
                default:
                    break
                }
                if queue.min != sorted.first || queue.max != sorted.last || queue.count != sorted.count {
                    failures.append("min \(String(describing: queue.min)), max \(String(describing: queue.max)), count \(queue.count); expected \(String(describing: sorted.first)), \(String(describing: sorted.last)), \(sorted.count)")
                }
                if failures.count >= 3 { break }
            }
            if failures.count >= 3 { break }
        }
        #expect(failures.isEmpty, "\(failures.prefix(3))")
    }

    @Test("Extremes of Int")
    func extremes() {
        var queue = Queue()
        for value in [0, Int.max, Int.min, Int.max, Int.min] { queue.insert(value) }
        #expect(queue.popMax() == Int.max)
        #expect(queue.popMin() == Int.min)
        #expect(queue.max == Int.max && queue.min == Int.min)
    }

    @Test("100,000 values inserted in increasing and decreasing order, popped from both ends", arguments: [true, false])
    func largeOrdered(increasing: Bool) {
        let n = 100_000
        var queue = Queue()
        for i in 0..<n { queue.insert(increasing ? i : n - 1 - i) }
        #expect(queue.min == 0 && queue.max == n - 1)
        var low = 0
        var high = n - 1
        var wrong = 0
        while low <= high {
            if queue.popMin() != low { wrong += 1 }
            low += 1
            if low <= high {
                if queue.popMax() != high { wrong += 1 }
                high -= 1
            }
        }
        #expect(wrong == 0)
        #expect(queue.isEmpty)
    }

    @Test("200,000 random operations on small values, checked against counts")
    func largeRandom() {
        var dice = Dice(state: 4_200)
        var queue = Queue()
        var counts = [Int](repeating: 0, count: 50)
        var total = 0
        var wrong = 0
        for _ in 0..<200_000 {
            switch dice.roll(3) {
            case 0, 1:
                let value = dice.roll(50)
                queue.insert(value)
                counts[value] += 1
                total += 1
            default:
                let fromBottom = dice.roll(2) == 0
                let expected = fromBottom ? counts.firstIndex { $0 > 0 } : counts.lastIndex { $0 > 0 }
                if let expected { counts[expected] -= 1; total -= 1 }
                if (fromBottom ? queue.popMin() : queue.popMax()) != expected { wrong += 1 }
            }
        }
        #expect(wrong == 0)
        #expect(queue.count == total)
    }
}
