import Testing
import DSAKit

@Suite struct QueueTests {
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

    private final class Token {
        static var alive = 0
        init() { Token.alive += 1 }
        deinit { Token.alive -= 1 }
    }

    @Test("A new queue is empty")
    func startsEmpty() {
        var queue = Queue<Int>()
        #expect(queue.isEmpty)
        #expect(queue.count == 0)
        #expect(queue.peek() == nil)
        #expect(queue.dequeue() == nil)
        #expect(Array(queue) == [])
    }

    @Test("First in, first out")
    func firstInFirstOut() {
        var queue = Queue<String>()
        queue.enqueue("a")
        queue.enqueue("b")
        queue.enqueue("c")
        #expect(queue.count == 3)
        #expect(queue.peek() == "a")
        #expect(queue.dequeue() == "a")
        #expect(queue.dequeue() == "b")
        queue.enqueue("d")
        #expect(queue.dequeue() == "c")
        #expect(queue.dequeue() == "d")
        #expect(queue.dequeue() == nil)
        #expect(queue.isEmpty)
    }

    @Test("A single element")
    func single() {
        var queue: Queue = [42]
        #expect(queue.count == 1)
        #expect(queue.peek() == 42)
        #expect(queue.dequeue() == 42)
        #expect(queue.isEmpty)
        queue.enqueue(7)
        #expect(queue.peek() == 7)
        #expect(queue.count == 1)
    }

    @Test("peek doesn't remove")
    func peekLeavesItThere() {
        let queue: Queue = [5, 6]
        #expect(queue.peek() == 5)
        #expect(queue.peek() == 5)
        #expect(queue.count == 2)
    }

    @Test("Iterates front to back without removing")
    func sequenceOrder() {
        var queue: Queue = [1, 2, 3, 4]
        queue.dequeue()
        queue.enqueue(5)
        #expect(Array(queue) == [2, 3, 4, 5])
        #expect(queue.map { $0 * 10 } == [20, 30, 40, 50])
        #expect(queue.reduce(0, +) == 14)
        #expect(queue.count == 4)
        #expect(queue.underestimatedCount == 4)
    }

    @Test("Literals, sequences and descriptions")
    func creation() {
        let fromLiteral: Queue = [1, 2, 3]
        let fromSequence = Queue(1...3)
        #expect(fromLiteral == fromSequence)
        #expect(fromLiteral.description == "Queue([1, 2, 3])")
        #expect(Queue<String>(["x", "y"]).description == "Queue([\"x\", \"y\"])")
        #expect(Queue<Int>().description == "Queue([])")
    }

    @Test("Equality ignores where the front sits in storage")
    func equality() {
        var shifted: Queue = [0, 0, 1, 2]
        shifted.dequeue()
        shifted.dequeue()
        #expect(shifted == [1, 2])
        #expect(shifted != [1, 2, 3])
        #expect(shifted != [2, 1])
    }

    @Test("Copies are independent")
    func valueSemantics() {
        var original: Queue = [1, 2]
        var copy = original
        copy.enqueue(3)
        copy.dequeue()
        #expect(Array(original) == [1, 2])
        #expect(Array(copy) == [2, 3])
        original.dequeue()
        #expect(Array(copy) == [2, 3])
    }

    @Test("removeAll empties the queue")
    func removeAll() {
        var queue: Queue = [1, 2, 3]
        queue.removeAll()
        #expect(queue.isEmpty)
        #expect(queue.dequeue() == nil)
        queue.enqueue(9)
        #expect(Array(queue) == [9])
    }

    @Test("Compacts past the threshold and keeps order")
    func compaction() {
        var queue = Queue(0..<100)
        for expected in 0..<70 {
            #expect(queue.dequeue() == expected)
        }
        #expect(queue.count == 30)
        #expect(Array(queue) == Array(70..<100))
        queue.enqueue(100)
        #expect(queue.peek() == 70)
        #expect(Array(queue).last == 100)
    }

    @Test("Releases dequeued objects once the queue empties")
    func releasesObjects() {
        Token.alive = 0
        var queue = Queue<Token>()
        for _ in 0..<10 {
            queue.enqueue(Token())
        }
        #expect(Token.alive == 10)
        while queue.dequeue() != nil {}
        #expect(Token.alive == 0)
    }

    @Test("Thousands of mixed operations match an Array model")
    func matchesModel() {
        var steps = Steps(seed: 2_027)
        var queue = Queue<Int>()
        var model: [Int] = []
        var mismatches = 0
        for value in 0..<20_000 {
            if steps.next(below: 5) < 3 {
                queue.enqueue(value)
                model.append(value)
            } else {
                let expected = model.isEmpty ? nil : model.removeFirst()
                if queue.dequeue() != expected { mismatches += 1 }
            }
            if queue.count != model.count || queue.peek() != model.first { mismatches += 1 }
            if value % 1_000 == 0 && !queue.elementsEqual(model) { mismatches += 1 }
        }
        #expect(mismatches == 0)
        #expect(Array(queue) == model)
    }

    @Test("Never-empty traffic stays correct and fast")
    func steadyTraffic() {
        // The queue hovers around 10 elements for 200,000 operations, compacting many times
        var queue = Queue(0..<10)
        var nextIn = 10
        var nextOut = 0
        var inOrder = true
        for _ in 0..<200_000 {
            queue.enqueue(nextIn)
            nextIn += 1
            if queue.dequeue() != nextOut { inOrder = false }
            nextOut += 1
        }
        #expect(inOrder)
        #expect(queue.count == 10)
        #expect(Array(queue) == Array(nextOut..<nextIn))
    }

    @Test("Handles 100,000 elements in and out")
    func large() {
        var queue = Queue<Int>()
        for value in 0..<100_000 {
            queue.enqueue(value)
        }
        #expect(queue.count == 100_000)
        var expected = 0
        var inOrder = true
        while let value = queue.dequeue() {
            if value != expected { inOrder = false }
            expected += 1
        }
        #expect(inOrder)
        #expect(expected == 100_000)
    }
}
