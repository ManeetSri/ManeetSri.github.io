import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct GrowableDequeTests {
    typealias RingDeque = GrowableDeque.RingDeque

    /// A tiny deterministic generator, so the mixed-operation test does the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    /// Reads the deque front to back through the subscript.
    private func contents<Element>(_ deque: RingDeque<Element>) -> [Element] {
        (0..<deque.count).compactMap { deque[$0] }
    }

    @Test("A new deque is empty")
    func startsEmpty() {
        var deque = RingDeque<Int>()
        #expect(deque.isEmpty)
        #expect(deque.count == 0)
        #expect(deque.first == nil)
        #expect(deque.last == nil)
        #expect(deque[0] == nil)
        #expect(deque.popFirst() == nil)
        #expect(deque.popLast() == nil)
    }

    @Test("Adds and removes at both ends")
    func bothEnds() {
        var deque = RingDeque<String>()
        deque.append("b")
        deque.prepend("a")
        deque.append("c")
        #expect(deque.count == 3)
        #expect(contents(deque) == ["a", "b", "c"])
        #expect(deque.first == "a")
        #expect(deque.last == "c")
        #expect(deque.popFirst() == "a")
        #expect(deque.popLast() == "c")
        #expect(deque.popLast() == "b")
        #expect(deque.isEmpty)
        #expect(deque.popFirst() == nil)
    }

    @Test("Works as a stack from either end")
    func stackLike() {
        var deque = RingDeque<Int>()
        for value in 1...5 { deque.prepend(value) }
        #expect(contents(deque) == [5, 4, 3, 2, 1])
        #expect(deque.popFirst() == 5)
        #expect(deque.popFirst() == 4)
        for value in 6...8 { deque.append(value) }
        #expect(deque.popLast() == 8)
        #expect(contents(deque) == [3, 2, 1, 6, 7])
    }

    @Test("The subscript returns nil outside 0..<count")
    func subscriptBounds() {
        var deque = RingDeque<Int>()
        deque.append(10)
        deque.append(20)
        #expect(deque[0] == 10)
        #expect(deque[1] == 20)
        #expect(deque[2] == nil)
        #expect(deque[-1] == nil)
    }

    @Test("Grows past many sizes, keeping the order")
    func growth() {
        var deque = RingDeque<Int>()
        var model: [Int] = []
        for value in 0..<1_000 {
            if value % 3 == 0 {
                deque.prepend(value)
                model.insert(value, at: 0)
            } else {
                deque.append(value)
                model.append(value)
            }
        }
        #expect(deque.count == 1_000)
        #expect(contents(deque) == model)
        #expect(deque.first == model.first)
        #expect(deque.last == model.last)
    }

    @Test("Wrap-around at both ends survives growth")
    func wrapThenGrow() {
        var deque = RingDeque<Int>()
        for value in 0..<6 { deque.append(value) }
        for _ in 0..<4 { _ = deque.popFirst() }          // the front moves along
        for value in 6..<12 { deque.append(value) }       // the back wraps round
        for value in (100..<104).reversed() { deque.prepend(value) }
        for value in 12..<40 { deque.append(value) }      // forces growth while wrapped
        let expected = Array(100..<104) + Array(4..<40)
        #expect(contents(deque) == expected)
    }

    @Test("Copies are independent")
    func valueSemantics() {
        var original = RingDeque<Int>()
        original.append(1)
        var copy = original
        copy.prepend(0)
        copy.append(2)
        #expect(original.count == 1)
        #expect(original.first == 1)
        #expect(contents(copy) == [0, 1, 2])
    }

    @Test("50,000 mixed operations match an Array model")
    func matchesModel() {
        var steps = Steps(seed: 2_024)
        var deque = RingDeque<Int>()
        var model: [Int] = []
        var mismatches = 0
        for value in 0..<50_000 {
            switch steps.next(below: 8) {
            case 0, 1:
                deque.append(value)
                model.append(value)
            case 2, 3:
                deque.prepend(value)
                model.insert(value, at: 0)
            case 4, 5:
                if deque.popFirst() != (model.isEmpty ? nil : model.removeFirst()) { mismatches += 1 }
            case 6:
                if deque.popLast() != model.popLast() { mismatches += 1 }
            default:
                if !model.isEmpty {
                    let position = steps.next(below: model.count)
                    if deque[position] != model[position] { mismatches += 1 }
                }
            }
            if deque.count != model.count || deque.first != model.first || deque.last != model.last {
                mismatches += 1
            }
        }
        #expect(mismatches == 0)
        #expect(contents(deque) == model)
    }

    @Test("Handles 200,000 operations at both ends")
    func large() {
        var deque = RingDeque<Int>()
        for value in 0..<100_000 {
            deque.append(value)
            deque.prepend(-value - 1)
        }
        #expect(deque.count == 200_000)
        #expect(deque.first == -100_000)
        #expect(deque.last == 99_999)
        #expect(deque[100_000] == 0)
        var balanced = true
        for offset in 0..<100_000 {
            if deque.popFirst() != -100_000 + offset || deque.popLast() != 99_999 - offset {
                balanced = false
            }
        }
        #expect(balanced)
        #expect(deque.isEmpty)
    }
}
