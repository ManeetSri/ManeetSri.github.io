import Testing
import DSAKit

@Suite struct DequeTests {
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

    @Test("A new deque is empty")
    func startsEmpty() {
        var deque = Deque<Int>()
        #expect(deque.isEmpty)
        #expect(deque.count == 0)
        #expect(deque.first == nil)
        #expect(deque.last == nil)
        #expect(deque.popFirst() == nil)
        #expect(deque.popLast() == nil)
        #expect(Array(deque) == [])
    }

    @Test("Adds and removes at both ends")
    func bothEnds() {
        var deque = Deque<String>()
        deque.append("b")
        deque.prepend("a")
        deque.append("c")
        #expect(Array(deque) == ["a", "b", "c"])
        #expect(deque.first == "a")
        #expect(deque.last == "c")
        #expect(deque.popFirst() == "a")
        #expect(deque.popLast() == "c")
        #expect(deque.popLast() == "b")
        #expect(deque.popFirst() == nil)
        #expect(deque.isEmpty)
    }

    @Test("A single element is both first and last")
    func single() {
        var deque: Deque = [7]
        #expect(deque.first == 7)
        #expect(deque.last == 7)
        #expect(deque.popLast() == 7)
        #expect(deque.isEmpty)
        deque.prepend(8)
        #expect(deque.popFirst() == 8)
        #expect(deque.isEmpty)
    }

    @Test("Prepending into an empty deque wraps to the last slot")
    func prependWraps() {
        var deque = Deque<Int>()
        for value in 1...5 {
            deque.prepend(value)
        }
        #expect(Array(deque) == [5, 4, 3, 2, 1])
        #expect(deque[0] == 5)
        #expect(deque[4] == 1)
    }

    @Test("Wraps round the end of its slots before growing")
    func wrapsAround() {
        var deque = Deque(0..<8)                  // exactly full: 8 slots
        #expect(deque.capacity == 8)
        #expect(deque.popFirst() == 0)
        #expect(deque.popFirst() == 1)
        deque.append(8)                           // lands in the slot 0 freed up
        deque.append(9)
        #expect(deque.capacity == 8)
        #expect(Array(deque) == Array(2...9))
        deque.prepend(1)                          // wraps the other way
        #expect(Array(deque) == Array(1...9))
    }

    @Test("Grows past its capacity and keeps the order")
    func growth() {
        var deque = Deque<Int>()
        for value in 0..<100 {
            if value.isMultiple(of: 2) {
                deque.append(value)
            } else {
                deque.prepend(value)
            }
        }
        #expect(deque.count == 100)
        #expect(deque.capacity >= 100)
        let expected = stride(from: 99, through: 1, by: -2).map { $0 } + stride(from: 0, through: 98, by: 2).map { $0 }
        #expect(Array(deque) == expected)
    }

    @Test("Growth while wrapped copies the elements in order")
    func growthWhileWrapped() {
        var deque = Deque(0..<8)
        deque.popFirst()
        deque.popFirst()
        deque.append(8)
        deque.append(9)                           // wrapped and full
        deque.append(10)                          // grows
        #expect(Array(deque) == Array(2...10))
        #expect(deque.capacity == 16)
    }

    @Test("Collection features come for free")
    func collection() {
        var deque: Deque = [3, 1, 2]
        deque.prepend(4)
        #expect(deque.map { $0 * 2 } == [8, 6, 2, 4])
        #expect(Array(deque.reversed()) == [2, 1, 3, 4])
        #expect(deque.contains(1))
        #expect(deque.firstIndex(of: 1) == 2)
        #expect(deque.max() == 4)
        #expect(Array(deque[1..<3]) == [3, 1])
        deque[0] = 0
        deque.sort()
        #expect(Array(deque) == [0, 1, 2, 3])
        deque.swapAt(0, 3)
        #expect(Array(deque) == [3, 1, 2, 0])
    }

    @Test("Literals, descriptions, equality and hashing")
    func conformances() {
        var shifted: Deque = [0, 1, 2]
        shifted.popFirst()
        shifted.append(3)
        let plain: Deque = [1, 2, 3]
        #expect(shifted == plain)
        #expect(Set([shifted, plain]).count == 1)
        #expect(plain.description == "Deque([1, 2, 3])")
        #expect(Deque<String>(["a"]).description == "Deque([\"a\"])")
        #expect(plain != [3, 2, 1])
    }

    @Test("Copies are independent")
    func valueSemantics() {
        var original: Deque = [1, 2]
        var copy = original
        copy.prepend(0)
        copy[1] = 10
        #expect(Array(original) == [1, 2])
        #expect(Array(copy) == [0, 10, 2])
        original.popLast()
        #expect(Array(copy) == [0, 10, 2])
    }

    @Test("removeAll empties it, optionally keeping capacity")
    func removeAll() {
        var deque = Deque(0..<20)
        let capacity = deque.capacity
        deque.removeAll(keepingCapacity: true)
        #expect(deque.isEmpty)
        #expect(deque.capacity == capacity)
        deque.prepend(1)
        #expect(Array(deque) == [1])
        deque.removeAll()
        #expect(deque.isEmpty)
        #expect(deque.capacity == 0)
        deque.append(2)
        #expect(Array(deque) == [2])
    }

    @Test("Thousands of mixed operations match an Array model", arguments: [1, 7, 42])
    func matchesModel(seed: UInt64) {
        var steps = Steps(seed: seed)
        var deque = Deque<Int>()
        var model: [Int] = []
        var mismatches = 0
        for value in 0..<20_000 {
            switch steps.next(below: 10) {
            case 0..<3:
                deque.append(value)
                model.append(value)
            case 3..<6:
                deque.prepend(value)
                model.insert(value, at: 0)
            case 6..<8:
                if deque.popFirst() != (model.isEmpty ? nil : model.removeFirst()) { mismatches += 1 }
            case 8:
                if deque.popLast() != model.popLast() { mismatches += 1 }
            default:
                if !model.isEmpty {
                    let position = steps.next(below: model.count)
                    if deque[position] != model[position] { mismatches += 1 }
                    deque[position] = -value
                    model[position] = -value
                }
            }
            if deque.count != model.count || deque.first != model.first || deque.last != model.last {
                mismatches += 1
            }
            if value % 500 == 0 && !deque.elementsEqual(model) { mismatches += 1 }
        }
        #expect(mismatches == 0)
        #expect(Array(deque) == model)
    }

    @Test("Handles 200,000 operations at both ends")
    func large() {
        var deque = Deque<Int>()
        for value in 0..<100_000 {
            deque.append(value)
            deque.prepend(-value - 1)
        }
        #expect(deque.count == 200_000)
        #expect(deque.first == -100_000)
        #expect(deque.last == 99_999)
        #expect(deque[100_000] == 0)
        var popped = 0
        while deque.popFirst() != nil && deque.popLast() != nil {
            popped += 2
        }
        #expect(popped == 200_000)
        #expect(deque.isEmpty)
    }
}
