import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct SpliceableLinkedQueueTests {
    typealias LinkedQueue = SpliceableLinkedQueue.LinkedQueue

    /// A tiny deterministic generator, so the mixed-operation test does the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    private func queue(_ items: [Int]) -> LinkedQueue<Int> {
        let result = LinkedQueue<Int>()
        for item in items {
            result.enqueue(item)
        }
        return result
    }

    @Test("A new queue is empty")
    func startsEmpty() {
        let line = LinkedQueue<Int>()
        #expect(line.isEmpty && line.count == 0)
        #expect(line.peek() == nil && line.dequeue() == nil)
        #expect(line.values == [])
    }

    @Test("First in, first out, and works again after emptying")
    func firstInFirstOut() {
        let line = LinkedQueue<String>()
        line.enqueue("a")
        line.enqueue("b")
        #expect(line.values == ["a", "b"] && line.count == 2)
        #expect(line.dequeue() == "a")
        #expect(line.dequeue() == "b")
        #expect(line.dequeue() == nil)
        line.enqueue("c")
        line.enqueue("d")
        #expect(line.values == ["c", "d"])
        #expect(line.peek() == "c" && line.count == 2 && !line.isEmpty)
    }

    @Test("Absorbing moves the whole line to the back")
    func absorbs() {
        let a = queue([1, 2])
        let b = queue([3, 4])
        a.absorb(b)
        #expect(a.values == [1, 2, 3, 4] && a.count == 4)
        #expect(b.values == [] && b.count == 0 && b.isEmpty && b.peek() == nil)
        #expect(a.dequeue() == 1 && a.peek() == 2)
    }

    @Test("The emptied line is independent and reusable")
    func otherReusable() {
        let a = queue([1, 2])
        let b = queue([3, 4])
        a.absorb(b)
        b.enqueue(9)
        #expect(b.values == [9] && b.count == 1)
        #expect(a.values == [1, 2, 3, 4] && a.count == 4)
        a.enqueue(5)
        #expect(a.values == [1, 2, 3, 4, 5] && b.values == [9])
    }

    @Test("Absorbing into an empty line, and absorbing an empty line")
    func emptyCases() {
        let a = LinkedQueue<Int>()
        let b = queue([5])
        a.absorb(b)
        a.enqueue(6)
        #expect(a.values == [5, 6] && a.count == 2)
        #expect(b.isEmpty)

        let c = queue([1])
        let d = LinkedQueue<Int>()
        c.absorb(d)
        #expect(c.values == [1] && c.count == 1)
        c.enqueue(2)
        #expect(c.values == [1, 2])

        let e = LinkedQueue<Int>()
        e.absorb(LinkedQueue<Int>())
        e.enqueue(3)
        #expect(e.values == [3])
    }

    @Test("Absorbing itself changes nothing")
    func absorbSelf() {
        let a = queue([1, 2, 3])
        a.absorb(a)
        #expect(a.values == [1, 2, 3] && a.count == 3)
        a.enqueue(4)
        #expect(a.values == [1, 2, 3, 4])
    }

    @Test("Absorbing after the absorbing line has been emptied by dequeues")
    func absorbAfterDrain() {
        let a = queue([1])
        #expect(a.dequeue() == 1)
        a.absorb(queue([2, 3]))
        #expect(a.values == [2, 3] && a.count == 2)
        a.enqueue(4)
        #expect(a.values == [2, 3, 4])
    }

    @Test("Mixed operations on three lines match Array models")
    func matchesModel() {
        var steps = Steps(seed: 2_701)
        let lines = [LinkedQueue<Int>(), LinkedQueue<Int>(), LinkedQueue<Int>()]
        var models: [[Int]] = [[], [], []]
        var mismatches = 0
        for value in 0..<6_000 {
            let pick = steps.next(below: 3)
            switch steps.next(below: 10) {
            case 0..<5:
                lines[pick].enqueue(value)
                models[pick].append(value)
            case 5..<8:
                let expected = models[pick].isEmpty ? nil : models[pick].removeFirst()
                if lines[pick].dequeue() != expected { mismatches += 1 }
            default:
                let other = steps.next(below: 3)
                lines[pick].absorb(lines[other])
                if other != pick {
                    models[pick] += models[other]
                    models[other] = []
                }
            }
            for index in 0..<3 where lines[index].count != models[index].count || lines[index].peek() != models[index].first {
                mismatches += 1
            }
        }
        for index in 0..<3 where lines[index].values != models[index] {
            mismatches += 1
        }
        #expect(mismatches == 0)
    }

    @Test("Absorbing is O(1), even for long lines")
    func large() {
        let a = queue(Array(0..<5_000))
        let b = queue(Array(5_000..<10_000))
        a.absorb(b)
        for round in 0..<100_000 {
            if round.isMultiple(of: 2) {
                b.absorb(a)
            } else {
                a.absorb(b)
            }
        }
        #expect(a.count == 10_000 && b.count == 0)
        #expect(a.values == Array(0..<10_000))
        #expect(a.dequeue() == 0 && a.peek() == 1)
    }
}
