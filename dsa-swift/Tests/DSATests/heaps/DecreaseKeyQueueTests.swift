import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

private typealias Queue = DecreaseKeyQueue.IndexedQueue

/// An optional (id, key) pair as an array, so results can be compared with ==.
private func pair(_ entry: (id: Int, key: Int)?) -> [Int] {
    entry.map { [$0.id, $0.key] } ?? []
}

private struct Dice {
    var state: UInt64
    mutating func roll(_ bound: Int) -> Int {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return Int(state >> 33) % bound
    }
}

@Suite struct DecreaseKeyQueueTests {
    @Test("The examples")
    func examples() {
        var queue = Queue(capacity: 5)
        for (id, key) in [0, 7, 9, 14, 20].enumerated() { queue.push(id, key: key) }
        #expect(pair(queue.peek()) == [0, 0])
        #expect(pair(queue.popMin()) == [0, 0])
        #expect(!queue.contains(0))
        queue.push(2, key: 5)
        queue.push(4, key: 11)
        #expect(pair(queue.popMin()) == [2, 5])
        queue.push(1, key: 30)
        #expect(pair(queue.peek()) == [4, 11])
        let removedOnce = queue.remove(3)
        let removedTwice = queue.remove(3)
        #expect(removedOnce)
        #expect(!removedTwice)
        #expect(queue.count == 2)
        #expect(queue.key(of: 1) == 30)
        #expect(queue.key(of: 3) == nil)

        var ties = Queue(capacity: 5)
        ties.push(3, key: 8)
        ties.push(0, key: 8)
        #expect(pair(ties.popMin()) == [0, 8])
        #expect(pair(ties.popMin()) == [3, 8])
        #expect(ties.popMin() == nil)
    }

    @Test("An empty queue")
    func empty() {
        var queue = Queue(capacity: 3)
        #expect(queue.isEmpty && queue.count == 0)
        #expect(queue.peek() == nil)
        #expect(queue.popMin() == nil)
        let removed = queue.remove(1)
        #expect(!removed)
        #expect(!queue.contains(2))
        #expect(queue.key(of: 0) == nil)
    }

    @Test("Ids can be popped, removed and pushed again")
    func reuse() {
        var queue = Queue(capacity: 2)
        queue.push(1, key: -5)
        #expect(pair(queue.popMin()) == [1, -5])
        queue.push(1, key: 50)
        queue.push(0, key: 60)
        let removed = queue.remove(1)
        #expect(removed)
        queue.push(1, key: 70)
        #expect(pair(queue.popMin()) == [0, 60])
        #expect(pair(queue.popMin()) == [1, 70])
        #expect(queue.isEmpty)
    }

    @Test("Raising and lowering keys reorders the queue")
    func changes() {
        var queue = Queue(capacity: 8)
        for id in 0..<8 { queue.push(id, key: 10 * id) }
        queue.push(0, key: 100)                  // the top sinks
        queue.push(7, key: -1)                   // the bottom rises
        queue.push(4, key: 40)                   // no change
        var order: [Int] = []
        while let (id, _) = queue.popMin() { order.append(id) }
        #expect(order == [7, 1, 2, 3, 4, 5, 6, 0])
    }

    @Test("Extremes of Int as keys")
    func extremes() {
        var queue = Queue(capacity: 3)
        queue.push(0, key: Int.max)
        queue.push(1, key: Int.min)
        queue.push(2, key: Int.max)
        #expect(pair(queue.popMin()) == [1, Int.min])
        #expect(pair(queue.popMin()) == [0, Int.max])
        #expect(pair(queue.popMin()) == [2, Int.max])
    }

    @Test("Copies are independent")
    func copies() {
        var first = Queue(capacity: 3)
        first.push(0, key: 5)
        first.push(1, key: 3)
        var second = first
        second.push(0, key: 1)
        _ = second.remove(1)
        #expect(pair(first.peek()) == [1, 3])
        #expect(first.count == 2)
        #expect(pair(second.peek()) == [0, 1])
        #expect(second.count == 1)
    }

    @Test("Random operations match a dictionary")
    func randomOperations() {
        var dice = Dice(state: 43)
        var failures: [String] = []
        for round in 0..<60 {
            let capacity = 1 + round % 20
            var queue = Queue(capacity: capacity)
            var reference: [Int: Int] = [:]
            for _ in 0..<300 {
                let id = dice.roll(capacity)
                switch dice.roll(6) {
                case 0, 1, 2:
                    let key = dice.roll(round % 2 == 0 ? 5 : 1_000)
                    queue.push(id, key: key)
                    reference[id] = key
                case 3:
                    if queue.remove(id) != (reference.removeValue(forKey: id) != nil) {
                        failures.append("remove(\(id)) gave the wrong answer")
                    }
                default:
                    let expected = reference.min { ($0.value, $0.key) < ($1.value, $1.key) }.map { [$0.key, $0.value] } ?? []
                    if let first = expected.first { reference[first] = nil }
                    let actual = pair(queue.popMin())
                    if actual != expected { failures.append("popMin gave \(actual), expected \(expected)") }
                }
                let top = reference.min { ($0.value, $0.key) < ($1.value, $1.key) }.map { [$0.key, $0.value] } ?? []
                if pair(queue.peek()) != top || queue.count != reference.count || queue.key(of: id) != reference[id] || queue.contains(id) != (reference[id] != nil) {
                    failures.append("after an operation on \(id): peek \(pair(queue.peek())), expected \(top)")
                }
                if failures.count >= 3 { break }
            }
            if failures.count >= 3 { break }
        }
        #expect(failures.isEmpty, "\(failures.prefix(3))")
    }

    @Test("50,000 ids and 200,000 key changes, then drained in order")
    func large() {
        let n = 50_000
        var dice = Dice(state: 4_300)
        var queue = Queue(capacity: n)
        var reference = [Int](repeating: 0, count: n)
        for id in 0..<n {
            reference[id] = dice.roll(1_000_000)
            queue.push(id, key: reference[id])
        }
        var wrong = 0
        for _ in 0..<200_000 {
            let id = dice.roll(n)
            let key = dice.roll(1_000_000)
            queue.push(id, key: key)
            reference[id] = key
            if queue.key(of: id) != key { wrong += 1 }
        }
        #expect(wrong == 0)
        #expect(queue.count == n)
        let expected = (0..<n).sorted { (reference[$0], $0) < (reference[$1], $1) }
        var drained: [Int] = []
        drained.reserveCapacity(n)
        while let (id, key) = queue.popMin() {
            if key != reference[id] { wrong += 1 }
            drained.append(id)
        }
        #expect(wrong == 0)
        #expect(drained == expected)
    }
}
