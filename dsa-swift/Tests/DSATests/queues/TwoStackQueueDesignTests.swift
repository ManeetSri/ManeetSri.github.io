import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct TwoStackQueueDesignTests {
    typealias TwoStackQueue = TwoStackQueueDesign.TwoStackQueue

    /// A tiny deterministic generator, so the mixed-operation test does the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    @Test("A new queue is empty")
    func startsEmpty() {
        var queue = TwoStackQueue<Int>()
        #expect(queue.isEmpty)
        #expect(queue.count == 0)
        #expect(queue.peek() == nil)
        #expect(queue.dequeue() == nil)
    }

    @Test("First in, first out")
    func firstInFirstOut() {
        var queue = TwoStackQueue<Int>()
        queue.enqueue(1)
        queue.enqueue(2)
        queue.enqueue(3)
        #expect(queue.count == 3)
        #expect(!queue.isEmpty)
        #expect(queue.dequeue() == 1)
        #expect(queue.dequeue() == 2)
        #expect(queue.dequeue() == 3)
        #expect(queue.dequeue() == nil)
        #expect(queue.isEmpty)
    }

    @Test("Enqueues and dequeues can interleave")
    func interleaved() {
        var queue = TwoStackQueue<String>()
        queue.enqueue("a")
        queue.enqueue("b")
        #expect(queue.dequeue() == "a")
        queue.enqueue("c")
        #expect(queue.peek() == "b")
        #expect(queue.dequeue() == "b")
        queue.enqueue("d")
        #expect(queue.count == 2)
        #expect(queue.dequeue() == "c")
        #expect(queue.dequeue() == "d")
        #expect(queue.isEmpty)
    }

    @Test("peek finds the front in either stack")
    func peekBothPlaces() {
        var queue = TwoStackQueue<Int>()
        queue.enqueue(5)
        queue.enqueue(6)
        #expect(queue.peek() == 5)               // still in the inbox, before any dequeue
        #expect(queue.count == 2)
        #expect(queue.dequeue() == 5)
        queue.enqueue(7)
        #expect(queue.peek() == 6)               // now in the outbox, with 7 in the inbox
        #expect(queue.dequeue() == 6)
        #expect(queue.peek() == 7)
    }

    @Test("Works again after being emptied")
    func reuse() {
        var queue = TwoStackQueue<Int>()
        queue.enqueue(1)
        #expect(queue.dequeue() == 1)
        #expect(queue.dequeue() == nil)
        queue.enqueue(2)
        queue.enqueue(3)
        #expect(queue.peek() == 2)
        #expect(queue.dequeue() == 2)
        #expect(queue.count == 1)
    }

    @Test("Copies are independent")
    func valueSemantics() {
        var original = TwoStackQueue<Int>()
        original.enqueue(1)
        original.enqueue(2)
        var copy = original
        #expect(copy.dequeue() == 1)
        copy.enqueue(3)
        #expect(original.count == 2)
        #expect(original.peek() == 1)
        #expect(copy.count == 2)
    }

    @Test("Thousands of mixed operations match an Array model")
    func matchesModel() {
        var steps = Steps(seed: 27)
        var queue = TwoStackQueue<Int>()
        var model: [Int] = []
        var mismatches = 0
        for value in 0..<20_000 {
            if steps.next(below: 3) < 2 {
                queue.enqueue(value)
                model.append(value)
            } else {
                let expected = model.isEmpty ? nil : model.removeFirst()
                if queue.dequeue() != expected { mismatches += 1 }
            }
            if queue.count != model.count || queue.peek() != model.first || queue.isEmpty != model.isEmpty {
                mismatches += 1
            }
        }
        #expect(mismatches == 0)
    }

    @Test("Stays amortised O(1) over 200,000 operations")
    func large() {
        var queue = TwoStackQueue<Int>()
        for value in 0..<1_000 {
            queue.enqueue(value)
        }
        var nextOut = 0
        var inOrder = true
        for value in 1_000..<101_000 {
            if queue.dequeue() != nextOut { inOrder = false }
            nextOut += 1
            queue.enqueue(value)
        }
        #expect(inOrder)
        #expect(queue.count == 1_000)
        #expect(queue.peek() == 100_000)
    }
}
