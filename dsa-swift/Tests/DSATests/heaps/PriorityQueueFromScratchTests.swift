import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct PriorityQueueFromScratchTests {
    typealias PriorityQueue = PriorityQueueFromScratch.PriorityQueue

    /// A tiny deterministic generator, so the mixed-operation test does the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    /// True when no element comes before its parent at (i - 1) / 2.
    private func isHeap<T>(_ items: [T], by areInIncreasingOrder: (T, T) -> Bool) -> Bool {
        !items.indices.dropFirst().contains { areInIncreasingOrder(items[$0], items[($0 - 1) / 2]) }
    }

    private func drain<T>(_ queue: PriorityQueue<T>) -> [T] {
        var queue = queue
        var result: [T] = []
        while let top = queue.pop(), result.count <= 1_000_000 {
            result.append(top)
        }
        return result
    }

    @Test("An empty queue")
    func empty() {
        var queue = PriorityQueue<Int>(areInIncreasingOrder: <)
        #expect(queue.isEmpty)
        #expect(queue.count == 0)
        #expect(queue.peek() == nil)
        #expect(queue.pop() == nil)
        #expect(queue.unordered == [])
    }

    @Test("A min-queue: insert, peek and pop")
    func minQueue() {
        var queue = PriorityQueue<Int>(areInIncreasingOrder: <)
        for value in [5, 3, 8, 1, 9, 2] {
            queue.insert(value)
            #expect(isHeap(queue.unordered, by: <))
        }
        #expect(queue.count == 6)
        #expect(!queue.isEmpty)
        #expect(queue.peek() == 1)
        #expect(queue.unordered.count == 6)
        #expect(queue.pop() == 1)
        #expect(queue.pop() == 2)
        #expect(queue.peek() == 3)
        #expect(isHeap(queue.unordered, by: <))
        #expect(drain(queue) == [3, 5, 8, 9])
    }

    @Test("Inserting into a min-queue lays the array out level by level")
    func layout() {
        var queue = PriorityQueue<Int>(areInIncreasingOrder: <)
        for value in [5, 3, 8, 1] {
            queue.insert(value)
        }
        #expect(queue.unordered == [1, 3, 8, 5])
        #expect(queue.pop() == 1)
        #expect(queue.unordered == [3, 5, 8])
    }

    @Test("A max-queue with > and duplicates")
    func maxQueue() {
        var queue = PriorityQueue<Int>(areInIncreasingOrder: >)
        for value in [4, 9, 4, 1, 9, 7] {
            queue.insert(value)
        }
        #expect(queue.peek() == 9)
        #expect(isHeap(queue.unordered, by: >))
        #expect(drain(queue) == [9, 9, 7, 4, 4, 1])
    }

    @Test("Any element type, ordered by a closure")
    func customOrder() {
        var errands = PriorityQueue<(minutes: Int, name: String)>(areInIncreasingOrder: { $0.minutes < $1.minutes })
        errands.insert((30, "shop"))
        errands.insert((5, "post letter"))
        errands.insert((15, "bank"))
        #expect(errands.peek()?.name == "post letter")
        #expect(drain(errands).map(\.name) == ["post letter", "bank", "shop"])
        let words = PriorityQueue(["kiwi", "fig", "banana"], areInIncreasingOrder: { $0.count < $1.count })
        #expect(drain(words) == ["fig", "kiwi", "banana"])
    }

    @Test("Building from an array gives a valid heap", arguments: [0, 1, 2, 3, 6, 7, 15, 16, 1_000])
    func heapify(count: Int) {
        let values = (0..<count).map { ($0 * 7_919) % 101 }
        let queue = PriorityQueue(values, areInIncreasingOrder: <)
        #expect(queue.count == count)
        #expect(queue.unordered.count == count)
        #expect(isHeap(queue.unordered, by: <))
        #expect(queue.unordered.sorted() == values.sorted())
        #expect(drain(queue) == values.sorted())
        let maxQueue = PriorityQueue(values, areInIncreasingOrder: >)
        #expect(isHeap(maxQueue.unordered, by: >))
        #expect(drain(maxQueue) == values.sorted(by: >))
    }

    @Test("Copies are independent")
    func valueSemantics() {
        var original = PriorityQueue([3, 1, 2], areInIncreasingOrder: <)
        var copy = original
        copy.insert(0)
        #expect(copy.peek() == 0)
        #expect(original.peek() == 1)
        #expect(original.pop() == 1)
        #expect(copy.count == 4)
    }

    @Test("20,000 mixed operations agree with a sorted array")
    func mixedOperations() {
        var steps = Steps(seed: 39)
        var queue = PriorityQueue<Int>(areInIncreasingOrder: <)
        var model: [Int] = []                             // decreasing, so the smallest is last
        var mismatches = 0
        for _ in 0..<20_000 {
            if steps.next(below: 10) < 6 {
                let value = steps.next(below: 1_000)
                queue.insert(value)
                let position = model.firstIndex { $0 < value } ?? model.count
                model.insert(value, at: position)
            } else if queue.pop() != model.popLast() {
                mismatches += 1
            }
            if queue.peek() != model.last || queue.count != model.count { mismatches += 1 }
        }
        #expect(mismatches == 0)
        #expect(isHeap(queue.unordered, by: <))
    }

    @Test("100,000 inserts in decreasing order, then 100,000 pops")
    func large() {
        var queue = PriorityQueue<Int>(areInIncreasingOrder: <)
        for value in stride(from: 100_000, to: 0, by: -1) {
            queue.insert(value)
        }
        #expect(queue.count == 100_000)
        #expect(queue.peek() == 1)
        var popped = 0
        var inOrder = true
        while let value = queue.pop(), popped < 100_000 {
            popped += 1
            if value != popped { inOrder = false }
        }
        #expect(popped == 100_000)
        #expect(inOrder)
        let built = PriorityQueue(Array((0..<100_000).reversed()), areInIncreasingOrder: <)
        #expect(built.peek() == 0)
        #expect(isHeap(built.unordered, by: <))
    }
}
