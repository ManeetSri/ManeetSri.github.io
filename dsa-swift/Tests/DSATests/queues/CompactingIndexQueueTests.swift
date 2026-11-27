import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct CompactingIndexQueueTests {
    typealias TicketQueue = CompactingIndexQueue.TicketQueue

    /// A tiny deterministic generator, so the mixed-operation test does the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    private func withinBound<Element>(_ queue: TicketQueue<Element>) -> Bool {
        queue.slotCount >= queue.count && queue.slotCount <= 2 * queue.count + 16
    }

    @Test("A new queue is empty")
    func startsEmpty() {
        var queue = TicketQueue<Int>()
        #expect(queue.isEmpty)
        #expect(queue.count == 0)
        #expect(queue.slotCount == 0)
        #expect(queue.peek() == nil)
        #expect(queue.dequeue() == nil)
    }

    @Test("First in, first out")
    func firstInFirstOut() {
        var queue = TicketQueue<String>()
        queue.enqueue("Ana")
        queue.enqueue("Ben")
        queue.enqueue("Cleo")
        #expect(queue.dequeue() == "Ana")
        #expect(queue.peek() == "Ben")
        #expect(queue.count == 2)
        queue.enqueue("Dev")
        #expect(queue.dequeue() == "Ben")
        #expect(queue.dequeue() == "Cleo")
        #expect(queue.dequeue() == "Dev")
        #expect(queue.dequeue() == nil)
        #expect(queue.isEmpty)
    }

    @Test("Emptying the queue frees every slot, and it works again afterwards")
    func resetWhenEmpty() {
        var queue = TicketQueue<Int>()
        for value in 1...3 { queue.enqueue(value) }
        #expect(queue.dequeue() == 1)
        #expect(queue.dequeue() == 2)
        #expect(queue.dequeue() == 3)
        #expect(queue.slotCount == 0)
        queue.enqueue(4)
        #expect(queue.peek() == 4 && queue.count == 1 && queue.slotCount == 1)
    }

    @Test("A busy counter that never empties stays small")
    func busyCounter() {
        var queue = TicketQueue<Int>()
        for ticket in 0..<3 { queue.enqueue(ticket) }
        var inOrder = true
        var bounded = true
        for ticket in 3..<1_003 {
            queue.enqueue(ticket)
            if queue.dequeue() != ticket - 3 { inOrder = false }
            if !withinBound(queue) { bounded = false }
        }
        #expect(inOrder && bounded)
        #expect(queue.count == 3)
        #expect(queue.slotCount <= 22)
        #expect(queue.peek() == 1_000)
    }

    @Test("Copies are independent")
    func valueSemantics() {
        var original = TicketQueue<Int>()
        original.enqueue(1)
        original.enqueue(2)
        var copy = original
        #expect(copy.dequeue() == 1)
        copy.enqueue(3)
        #expect(original.count == 2 && original.peek() == 1)
        #expect(copy.count == 2 && copy.peek() == 2)
    }

    @Test("Thousands of mixed operations match an Array model and keep within the bound")
    func matchesModel() {
        var steps = Steps(seed: 27)
        var queue = TicketQueue<Int>()
        var model: [Int] = []
        var mismatches = 0
        for value in 0..<20_000 {
            if steps.next(below: 100) < (value < 10_000 ? 60 : 40) {
                queue.enqueue(value)
                model.append(value)
            } else {
                let expected = model.isEmpty ? nil : model.removeFirst()
                if queue.dequeue() != expected { mismatches += 1 }
                if model.isEmpty && queue.slotCount != 0 { mismatches += 1 }
            }
            if queue.count != model.count || queue.peek() != model.first || queue.isEmpty != model.isEmpty || !withinBound(queue) {
                mismatches += 1
            }
        }
        #expect(mismatches == 0)
    }

    @Test("Stays O(1) amortised with 50,000 items waiting")
    func large() {
        var queue = TicketQueue<Int>()
        for value in 0..<50_000 {
            queue.enqueue(value)
        }
        var inOrder = true
        var largest = 0
        for value in 50_000..<150_000 {
            queue.enqueue(value)
            if queue.dequeue() != value - 50_000 { inOrder = false }
            largest = max(largest, queue.slotCount)
        }
        #expect(inOrder)
        #expect(queue.count == 50_000)
        #expect(largest <= 2 * 50_000 + 16)
    }
}
