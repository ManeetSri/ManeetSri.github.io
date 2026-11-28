import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct QueueBuiltStackTests {
    typealias QueueStack = QueueBuiltStack.QueueStack

    /// A tiny deterministic generator, so the mixed-operation test does the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    @Test("A new stack is empty")
    func startsEmpty() {
        var stack = QueueStack<Int>()
        #expect(stack.isEmpty && stack.count == 0)
        #expect(stack.top() == nil && stack.pop() == nil)
    }

    @Test("Last in, first out")
    func lastInFirstOut() {
        var stack = QueueStack<Int>()
        stack.push(1)
        stack.push(2)
        stack.push(3)
        #expect(stack.count == 3 && !stack.isEmpty)
        #expect(stack.top() == 3)
        #expect(stack.pop() == 3)
        #expect(stack.top() == 2)
        #expect(stack.pop() == 2)
        #expect(stack.pop() == 1)
        #expect(stack.top() == nil && stack.pop() == nil && stack.isEmpty)
    }

    @Test("Pushes and pops can interleave")
    func interleaved() {
        var stack = QueueStack<String>()
        stack.push("a")
        stack.push("b")
        #expect(stack.pop() == "b")
        stack.push("c")
        #expect(stack.top() == "c" && stack.count == 2)
        #expect(stack.pop() == "c")
        #expect(stack.pop() == "a")
        stack.push("d")
        #expect(stack.top() == "d" && stack.pop() == "d" && stack.pop() == nil)
    }

    @Test("Copies are independent")
    func valueSemantics() {
        var original = QueueStack<Int>()
        original.push(1)
        original.push(2)
        var copy = original
        #expect(copy.pop() == 2)
        copy.push(3)
        #expect(original.count == 2 && original.top() == 2)
        #expect(copy.count == 2 && copy.top() == 3)
    }

    @Test("Thousands of mixed operations match an Array model")
    func matchesModel() {
        var steps = Steps(seed: 2_783)
        var stack = QueueStack<Int>()
        var model: [Int] = []
        var mismatches = 0
        for value in 0..<5_000 {
            if steps.next(below: 5) < 3 {
                stack.push(value)
                model.append(value)
            } else if stack.pop() != model.popLast() {
                mismatches += 1
            }
            if stack.count != model.count || stack.top() != model.last || stack.isEmpty != model.isEmpty {
                mismatches += 1
            }
        }
        #expect(mismatches == 0)
    }

    @Test("Push and top stay O(1) over 20,000 pushes")
    func large() {
        var stack = QueueStack<Int>()
        var topsRight = true
        for value in 0..<20_000 {
            stack.push(value)
            if stack.top() != value { topsRight = false }
        }
        #expect(topsRight)
        #expect(stack.count == 20_000)
        #expect(stack.pop() == 19_999)
        #expect(stack.top() == 19_998)
        #expect(stack.pop() == 19_998)
        stack.push(-1)
        #expect(stack.top() == -1 && stack.pop() == -1)
        #expect(stack.pop() == 19_997 && stack.count == 19_997)
    }
}
