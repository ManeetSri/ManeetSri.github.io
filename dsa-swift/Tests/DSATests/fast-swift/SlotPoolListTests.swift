import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same operations
private struct SlotPoolRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

/// The same list kept as a plain array of (handle, value) pairs, with the free-slot rule spelled out.
/// O(n) per operation, which is fine for small tests.
private struct SlotPoolModel {
    var entries: [(handle: Int, value: Int)] = []
    var free: [Int] = []
    var slots = 0

    mutating func newHandle() -> Int {
        if let handle = free.popLast() {
            return handle
        }
        slots += 1
        return slots - 1
    }

    mutating func pushFront(_ value: Int) -> Int {
        let handle = newHandle()
        entries.insert((handle, value), at: 0)
        return handle
    }

    mutating func pushBack(_ value: Int) -> Int {
        let handle = newHandle()
        entries.append((handle, value))
        return handle
    }

    mutating func insert(_ value: Int, after existing: Int) -> Int {
        let position = entries.firstIndex { $0.handle == existing }!
        let handle = newHandle()
        entries.insert((handle, value), at: position + 1)
        return handle
    }

    mutating func remove(_ handle: Int) -> Int {
        let position = entries.firstIndex { $0.handle == handle }!
        free.append(handle)
        return entries.remove(at: position).value
    }
}

@Suite struct SlotPoolListTests {
    typealias List = SlotPoolList.List

    @Test("A new list is empty")
    func empty() {
        let list = List()
        #expect(list.count == 0)
        #expect(list.slotCount == 0)
        #expect(list.values == [])
        #expect(list.valuesBackward == [])
    }

    @Test("Pushing at both ends")
    func pushes() {
        var list = List()
        #expect(list.pushBack(2) == 0)
        #expect(list.pushBack(3) == 1)
        #expect(list.pushFront(1) == 2)
        #expect(list.values == [1, 2, 3])
        #expect(list.valuesBackward == [3, 2, 1])
        #expect(list.count == 3)
        #expect(list.slotCount == 3)
        #expect(list.value(at: 2) == 1)
        #expect(list.value(at: 0) == 2)
    }

    @Test("The statement's example: a freed slot is reused")
    func example() {
        var list = List()
        list.pushBack(10)                       // slot 0
        let middle = list.pushBack(20)          // slot 1
        list.pushBack(30)                       // slot 2
        #expect(list.remove(middle) == 20)
        #expect(list.values == [10, 30])
        #expect(list.pushFront(5) == 1)         // reuses slot 1
        #expect(list.values == [5, 10, 30])
        #expect(list.valuesBackward == [30, 10, 5])
        #expect(list.slotCount == 3)
        #expect(list.count == 3)
    }

    @Test("Inserting after a node, including after the last one")
    func insertAfter() {
        var list = List()
        let first = list.pushBack(1)
        let last = list.pushBack(4)
        let two = list.insert(2, after: first)
        list.insert(3, after: two)
        list.insert(5, after: last)
        #expect(list.values == [1, 2, 3, 4, 5])
        #expect(list.valuesBackward == [5, 4, 3, 2, 1])
        list.pushBack(6)
        #expect(list.values == [1, 2, 3, 4, 5, 6], "inserting after the last node must update the back")
    }

    @Test("Removing the front, the back and the only node")
    func removeEnds() {
        var list = List()
        let a = list.pushBack(1)
        let b = list.pushBack(2)
        let c = list.pushBack(3)
        #expect(list.remove(a) == 1)
        #expect(list.values == [2, 3])
        #expect(list.remove(c) == 3)
        #expect(list.values == [2])
        #expect(list.valuesBackward == [2])
        #expect(list.remove(b) == 2)
        #expect(list.count == 0)
        #expect(list.values == [])
        #expect(list.valuesBackward == [])
        list.pushBack(7)
        list.pushFront(6)
        #expect(list.values == [6, 7])
        #expect(list.valuesBackward == [7, 6])
        #expect(list.slotCount == 3)
    }

    @Test("Freed slots are reused most recently freed first")
    func reuseOrder() {
        var list = List()
        for value in 0..<6 {
            list.pushBack(value)
        }
        list.remove(0)
        list.remove(2)
        list.remove(4)
        #expect(list.pushBack(100) == 4)
        #expect(list.pushFront(101) == 2)
        #expect(list.insert(102, after: 4) == 0)
        #expect(list.pushBack(103) == 6, "with no free slot left, a new slot is created")
        #expect(list.values == [101, 1, 3, 5, 100, 102, 103])
        #expect(list.slotCount == 7)
    }

    @Test("Copies are independent values")
    func valueSemantics() {
        var original = List()
        let handle = original.pushBack(1)
        original.pushBack(2)
        var copy = original
        copy.remove(handle)
        copy.pushBack(3)
        #expect(original.values == [1, 2])
        #expect(copy.values == [2, 3])
        original.pushFront(0)
        #expect(copy.values == [2, 3])
    }

    @Test("Matches a simple model on random operations")
    func randomOperations() {
        var random = SlotPoolRandom(seed: 68)
        for _ in 0..<40 {
            var list = List()
            var model = SlotPoolModel()
            for step in 0..<120 {
                let live = model.entries.map(\.handle)
                let choice = live.isEmpty ? Int.random(in: 0...1, using: &random) : Int.random(in: 0...4, using: &random)
                switch choice {
                case 0:
                    #expect(list.pushFront(step) == model.pushFront(step))
                case 1:
                    #expect(list.pushBack(step) == model.pushBack(step))
                case 2:
                    let after = live.randomElement(using: &random)!
                    #expect(list.insert(step, after: after) == model.insert(step, after: after))
                default:
                    let handle = live.randomElement(using: &random)!
                    #expect(list.remove(handle) == model.remove(handle))
                }
                #expect(list.count == model.entries.count)
                #expect(list.slotCount == model.slots)
            }
            #expect(list.values == model.entries.map(\.value))
            #expect(list.valuesBackward == model.entries.reversed().map(\.value))
            for entry in model.entries {
                #expect(list.value(at: entry.handle) == entry.value)
            }
        }
    }

    @Test("100,000 nodes: remove half from the middle, then put them back")
    func largeRebuild() {
        let n = 100_000
        var list = List()
        for value in 0..<n {
            list.pushBack(value)                 // value v lives in slot v
        }
        for value in stride(from: 1, to: n, by: 2) {
            list.remove(value)                   // frees slots 1, 3, 5, …, n - 1, in that order
        }
        #expect(list.count == n / 2)
        // Put each odd value back after its even neighbour. Slots come off the free list in reverse
        // order, so value v gets slot n - v.
        for value in stride(from: 0, to: n, by: 2) {
            let handle = list.insert(value + 1, after: value)
            if handle != n - (value + 1) {
                Issue.record("value \(value + 1) should reuse slot \(n - (value + 1)), got \(handle)")
                return
            }
        }
        #expect(list.slotCount == n)
        #expect(list.count == n)
        #expect(list.values == Array(0..<n))
        #expect(list.valuesBackward == Array((0..<n).reversed()))
        #expect(list.value(at: n - 1) == 1)
    }

    @Test("200,000 rounds of remove-front and push-back keep the pool at its peak size")
    func churn() {
        let live = 1_000
        var list = List()
        var handles: [Int] = []                  // a queue of handles, front at `front`
        for value in 0..<live {
            handles.append(list.pushBack(value))
        }
        var front = 0
        for round in 0..<200_000 {
            let removed = list.remove(handles[front])
            front += 1
            if removed != round {
                Issue.record("round \(round) removed \(removed)")
                return
            }
            handles.append(list.pushBack(live + round))
        }
        #expect(list.slotCount == live)
        #expect(list.count == live)
        #expect(list.values == Array(200_000..<(200_000 + live)))
    }
}
