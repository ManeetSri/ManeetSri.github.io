import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct MinStackDesignTests {
    typealias MinStack = MinStackDesign.MinStack

    @Test("A new stack is empty")
    func startsEmpty() {
        var stack = MinStack()
        #expect(stack.count == 0)
        #expect(stack.top == nil)
        #expect(stack.minimum == nil)
        #expect(stack.pop() == nil)
    }

    @Test("Tracks the minimum through pushes and pops")
    func example() {
        var stack = MinStack()
        stack.push(5)
        stack.push(8)
        #expect(stack.minimum == 5)
        stack.push(3)
        #expect(stack.minimum == 3)
        #expect(stack.top == 3)
        #expect(stack.pop() == 3)
        #expect(stack.minimum == 5)
        #expect(stack.top == 8)
        #expect(stack.count == 2)
    }

    @Test("Duplicate minimums survive a pop")
    func duplicates() {
        var stack = MinStack()
        stack.push(2)
        stack.push(1)
        stack.push(1)
        #expect(stack.pop() == 1)
        #expect(stack.minimum == 1)
        #expect(stack.pop() == 1)
        #expect(stack.minimum == 2)
        #expect(stack.pop() == 2)
        #expect(stack.minimum == nil)
    }

    @Test("Negative values and the extremes of Int")
    func extremes() {
        var stack = MinStack()
        stack.push(Int.max)
        stack.push(-4)
        stack.push(Int.min)
        #expect(stack.minimum == Int.min)
        stack.pop()
        #expect(stack.minimum == -4)
        stack.pop()
        #expect(stack.minimum == Int.max)
    }

    @Test("Matches a brute force over a long mixed sequence")
    func matchesBruteForce() {
        var stack = MinStack()
        var model: [Int] = []
        var mismatches = 0
        for step in 0..<3_000 {
            if step % 3 == 2 {
                if stack.pop() != model.popLast() {
                    mismatches += 1
                }
            } else {
                let value = (step * 37) % 101 - 50
                stack.push(value)
                model.append(value)
            }
            if stack.minimum != model.min() || stack.top != model.last || stack.count != model.count {
                mismatches += 1
            }
        }
        #expect(mismatches == 0)
    }

    @Test("Stays fast with 200,000 operations")
    func large() {
        var stack = MinStack()
        for value in (0..<100_000).reversed() {
            stack.push(value)
        }
        #expect(stack.minimum == 0)
        var wrong = 0
        for expectedMinimum in 0..<100_000 {
            if stack.minimum != expectedMinimum {
                wrong += 1
            }
            stack.pop()
        }
        #expect(wrong == 0)
        #expect(stack.count == 0)
    }
}
