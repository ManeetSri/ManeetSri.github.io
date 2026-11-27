import Testing
import DSAKit

@Suite struct RingBufferTests {
    /// A tiny deterministic generator, so the mixed-operation tests do the same thing every run.
    private struct Steps {
        private var state: UInt64

        init(seed: UInt64) {
            state = seed
        }

        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    @Test("A new buffer is empty")
    func startsEmpty() {
        var buffer = RingBuffer<Int>(capacity: 3)
        #expect(buffer.isEmpty)
        #expect(!buffer.isFull)
        #expect(buffer.count == 0)
        #expect(buffer.capacity == 3)
        #expect(buffer.first == nil)
        #expect(buffer.last == nil)
        #expect(buffer.popFirst() == nil)
        #expect(buffer.popLast() == nil)
        #expect(Array(buffer) == [])
    }

    @Test("Fills up in order")
    func fills() {
        var buffer = RingBuffer<String>(capacity: 3)
        #expect(buffer.append("a") == nil)
        #expect(buffer.append("b") == nil)
        #expect(!buffer.isFull)
        #expect(buffer.append("c") == nil)
        #expect(buffer.isFull)
        #expect(buffer.count == 3)
        #expect(Array(buffer) == ["a", "b", "c"])
        #expect(buffer.first == "a")
        #expect(buffer.last == "c")
        #expect(buffer[1] == "b")
    }

    @Test("When full, append overwrites and returns the oldest")
    func overwritesOldest() {
        var buffer = RingBuffer(capacity: 3, [1, 2, 3])
        #expect(buffer.append(4) == 1)
        #expect(Array(buffer) == [2, 3, 4])
        #expect(buffer.append(5) == 2)
        #expect(buffer.append(6) == 3)
        #expect(buffer.append(7) == 4)
        #expect(Array(buffer) == [5, 6, 7])
        #expect(buffer.count == 3)
        #expect(buffer.first == 5)
        #expect(buffer.last == 7)
    }

    @Test("Creating from more elements than fit keeps the newest")
    func initKeepsNewest() {
        let buffer = RingBuffer(capacity: 4, 1...10)
        #expect(Array(buffer) == [7, 8, 9, 10])
        #expect(buffer.isFull)
    }

    @Test("Capacity 1 holds only the newest element")
    func capacityOne() {
        var buffer = RingBuffer<Int>(capacity: 1)
        #expect(buffer.append(1) == nil)
        #expect(buffer.isFull)
        #expect(buffer.append(2) == 1)
        #expect(buffer.first == 2)
        #expect(buffer.last == 2)
        #expect(buffer.popLast() == 2)
        #expect(buffer.isEmpty)
        #expect(buffer.append(3) == nil)
        #expect(buffer.popFirst() == 3)
    }

    @Test("Wraps round the end of its slots")
    func wrapsAround() {
        var buffer = RingBuffer<Int>(capacity: 4)
        for value in 1...4 { buffer.append(value) }
        #expect(buffer.popFirst() == 1)
        #expect(buffer.popFirst() == 2)
        buffer.append(5)
        buffer.append(6)                 // these two land in the slots 1 and 2 freed up
        #expect(Array(buffer) == [3, 4, 5, 6])
        #expect(buffer[0] == 3)
        #expect(buffer[3] == 6)
        #expect(buffer.popLast() == 6)
        #expect(buffer.popFirst() == 3)
        #expect(Array(buffer) == [4, 5])
    }

    @Test("Subscript reads and writes by position from the oldest")
    func subscripts() {
        var buffer = RingBuffer(capacity: 3, [10, 20, 30, 40])
        #expect(buffer[0] == 20)
        buffer[0] = 21
        buffer[2] = 41
        #expect(Array(buffer) == [21, 30, 41])
    }

    @Test("removeAll keeps the capacity")
    func removeAll() {
        var buffer = RingBuffer(capacity: 3, [1, 2, 3])
        buffer.removeAll()
        #expect(buffer.isEmpty)
        #expect(buffer.capacity == 3)
        buffer.append(9)
        #expect(Array(buffer) == [9])
    }

    @Test("Descriptions and equality")
    func describesAndCompares() {
        var a = RingBuffer(capacity: 3, [1, 2, 3, 4])   // wrapped: [2, 3, 4]
        let b = RingBuffer(capacity: 3, [2, 3, 4])      // not wrapped
        #expect(a == b)
        #expect(a.description == "RingBuffer([2, 3, 4], capacity: 3)")
        #expect(a != RingBuffer(capacity: 4, [2, 3, 4]))
        a.popLast()
        #expect(a != b)
        #expect(RingBuffer<Int>(capacity: 2).description == "RingBuffer([], capacity: 2)")
    }

    @Test("Copies are independent")
    func valueSemantics() {
        var original = RingBuffer(capacity: 2, [1, 2])
        var copy = original
        copy.append(3)
        #expect(Array(original) == [1, 2])
        #expect(Array(copy) == [2, 3])
        original.popFirst()
        #expect(Array(copy) == [2, 3])
    }

    @Test("Thousands of mixed operations match an Array model", arguments: [1, 2, 5, 16])
    func matchesModel(capacity: Int) {
        var steps = Steps(seed: UInt64(capacity) * 97)
        var buffer = RingBuffer<Int>(capacity: capacity)
        var model: [Int] = []
        var mismatches = 0
        for value in 0..<10_000 {
            switch steps.next(below: 10) {
            case 0..<6:
                let evicted = buffer.append(value)
                model.append(value)
                let expected = model.count > capacity ? model.removeFirst() : nil
                if evicted != expected { mismatches += 1 }
            case 6..<8:
                if buffer.popFirst() != (model.isEmpty ? nil : model.removeFirst()) { mismatches += 1 }
            case 8:
                if buffer.popLast() != model.popLast() { mismatches += 1 }
            default:
                if let position = model.indices.last, buffer[position] != model[position] { mismatches += 1 }
            }
            if buffer.count != model.count || buffer.first != model.first || buffer.last != model.last {
                mismatches += 1
            }
            if buffer.isFull != (model.count == capacity) { mismatches += 1 }
            if !buffer.elementsEqual(model) { mismatches += 1 }
        }
        #expect(mismatches == 0)
    }

    @Test("A million appends stay within capacity")
    func large() {
        var buffer = RingBuffer<Int>(capacity: 1_000)
        var evictedTotal = 0
        for value in 0..<1_000_000 {
            evictedTotal += buffer.append(value) ?? 0
        }
        #expect(buffer.count == 1_000)
        #expect(buffer.first == 999_000)
        #expect(buffer.last == 999_999)
        // Everything below 999,000 was evicted exactly once
        #expect(evictedTotal == (0..<999_000).reduce(0, +))
    }
}
