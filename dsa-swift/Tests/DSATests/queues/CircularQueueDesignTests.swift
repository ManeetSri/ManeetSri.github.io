import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct CircularQueueDesignTests {
    typealias CircularQueue = CircularQueueDesign.CircularQueue

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
        var queue = CircularQueue<Int>(capacity: 3)
        #expect(queue.capacity == 3)
        #expect(queue.isEmpty)
        #expect(!queue.isFull)
        #expect(queue.count == 0)
        #expect(queue.front == nil)
        #expect(queue.back == nil)
        #expect(queue.dequeue() == nil)
    }

    @Test("Fills up, then refuses")
    func refusesWhenFull() {
        var queue = CircularQueue<String>(capacity: 3)
        #expect(queue.enqueue("a") == true)
        #expect(queue.enqueue("b") == true)
        #expect(queue.enqueue("c") == true)
        #expect(queue.isFull)
        #expect(queue.enqueue("d") == false)
        #expect(queue.count == 3)
        #expect(queue.front == "a")
        #expect(queue.back == "c")
        #expect(queue.dequeue() == "a")
        #expect(!queue.isFull)
        #expect(queue.enqueue("d") == true)
        #expect(queue.back == "d")
    }

    @Test("Wraps round the end of its slots")
    func wrapsAround() {
        var queue = CircularQueue<Int>(capacity: 4)
        for value in 1...3 { _ = queue.enqueue(value) }
        #expect(queue.dequeue() == 1)
        #expect(queue.dequeue() == 2)
        #expect(queue.enqueue(4) == true)
        #expect(queue.enqueue(5) == true)                // wraps to the first slot
        #expect(queue.enqueue(6) == true)
        #expect(queue.isFull)
        #expect(queue.front == 3)
        #expect(queue.back == 6)
        var drained: [Int] = []
        while let value = queue.dequeue() {
            drained.append(value)
        }
        #expect(drained == [3, 4, 5, 6])
        #expect(queue.isEmpty)
    }

    @Test("Capacity 1 holds a single element")
    func capacityOne() {
        var queue = CircularQueue<Int>(capacity: 1)
        #expect(queue.enqueue(7) == true)
        #expect(queue.isFull)
        #expect(queue.enqueue(8) == false)
        #expect(queue.front == 7)
        #expect(queue.back == 7)
        #expect(queue.dequeue() == 7)
        #expect(queue.isEmpty)
        #expect(queue.enqueue(9) == true)
        #expect(queue.front == 9)
    }

    @Test("A refused enqueue changes nothing")
    func refusalLeavesQueueAlone() {
        var queue = CircularQueue<Int>(capacity: 2)
        _ = queue.enqueue(1)
        _ = queue.enqueue(2)
        #expect(queue.enqueue(3) == false)
        #expect(queue.enqueue(4) == false)
        #expect(queue.dequeue() == 1)
        #expect(queue.dequeue() == 2)
        #expect(queue.dequeue() == nil)
    }

    @Test("Copies are independent")
    func valueSemantics() {
        var original = CircularQueue<Int>(capacity: 2)
        _ = original.enqueue(1)
        var copy = original
        _ = copy.enqueue(2)
        #expect(original.count == 1)
        #expect(original.back == 1)
        #expect(copy.back == 2)
    }

    @Test("Thousands of mixed operations match an Array model", arguments: [1, 3, 8])
    func matchesModel(capacity: Int) {
        var steps = Steps(seed: UInt64(capacity) &* 31)
        var queue = CircularQueue<Int>(capacity: capacity)
        var model: [Int] = []
        var mismatches = 0
        for value in 0..<20_000 {
            if steps.next(below: 2) == 0 {
                let accepted = queue.enqueue(value)
                if model.count < capacity {
                    model.append(value)
                    if !accepted { mismatches += 1 }
                } else if accepted {
                    mismatches += 1
                }
            } else {
                let expected = model.isEmpty ? nil : model.removeFirst()
                if queue.dequeue() != expected { mismatches += 1 }
            }
            if queue.count != model.count || queue.front != model.first || queue.back != model.last {
                mismatches += 1
            }
            if queue.isEmpty != model.isEmpty || queue.isFull != (model.count == capacity) {
                mismatches += 1
            }
        }
        #expect(mismatches == 0)
    }

    @Test("A busy queue of capacity 1,000 stays fast")
    func large() {
        var queue = CircularQueue<Int>(capacity: 1_000)
        var nextIn = 0
        var nextOut = 0
        var correct = true
        for round in 0..<200_000 {
            if round % 3 != 2 {
                if queue.enqueue(nextIn) {
                    nextIn += 1
                } else if queue.count != 1_000 {
                    correct = false              // refused while there was room
                }
            } else if let value = queue.dequeue() {
                if value != nextOut { correct = false }
                nextOut += 1
            }
        }
        #expect(correct)
        #expect(queue.isFull)
        #expect(queue.count == nextIn - nextOut)
        #expect(queue.front == nextOut)
    }
}
