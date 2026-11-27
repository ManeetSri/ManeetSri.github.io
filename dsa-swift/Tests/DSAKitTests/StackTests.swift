import Testing
import DSAKit

@Suite struct StackTests {
    @Test("A new stack is empty")
    func startsEmpty() {
        var stack = Stack<Int>()
        #expect(stack.isEmpty)
        #expect(stack.count == 0)
        #expect(stack.peek() == nil)
        #expect(stack.top == nil)
        #expect(stack.pop() == nil)
        #expect(stack.isEmpty)
        #expect(Array(stack).isEmpty)
        #expect(stack.description == "Stack (empty)")
    }

    @Test("A single element")
    func single() {
        var stack = Stack<String>()
        stack.push("only")
        #expect(stack.count == 1)
        #expect(stack.peek() == "only")
        #expect(stack.top == "only")
        #expect(stack.pop() == "only")
        #expect(stack.pop() == nil)
        #expect(stack.isEmpty)
    }

    @Test("Last in, first out, with pushes and pops interleaved")
    func lastInFirstOut() {
        var stack = Stack<Int>()
        stack.push(1)
        stack.push(2)
        #expect(stack.pop() == 2)
        stack.push(3)
        stack.push(4)
        #expect(stack.count == 3)
        #expect(stack.pop() == 4)
        #expect(stack.pop() == 3)
        #expect(stack.peek() == 1)
        #expect(stack.pop() == 1)
        #expect(stack.pop() == nil)
    }

    @Test("peek leaves the top in place")
    func peekDoesNotRemove() {
        var stack: Stack = ["a", "b"]
        #expect(stack.peek() == "b")
        #expect(stack.peek() == "b")
        #expect(stack.count == 2)
        stack.pop()
        #expect(stack.peek() == "a")
    }

    @Test("An array literal lists elements bottom to top")
    func literal() {
        var stack: Stack = [1, 2, 3]
        #expect(stack.count == 3)
        #expect(stack.pop() == 3)
        let empty: Stack<Int> = []
        #expect(empty.isEmpty)
        let fromSequence = Stack(1...4)
        #expect(fromSequence.top == 4)
    }

    @Test("Iterating goes from the top down without popping")
    func sequenceOrder() {
        let stack: Stack = [10, 20, 30]
        #expect(Array(stack) == [30, 20, 10])
        #expect(stack.map { $0 / 10 } == [3, 2, 1])
        #expect(stack.first(where: { $0 < 25 }) == 20)
        #expect(stack.contains(10))
        #expect(stack.count == 3)
        #expect(stack.underestimatedCount == 3)
        var popped: [Int] = []
        var copy = stack
        while let value = copy.pop() {
            popped.append(value)
        }
        #expect(popped == Array(stack))
    }

    @Test("Describes itself bottom to top with the top marked")
    func description() {
        let stack: Stack = [4, 8, 15]
        #expect(stack.description == "Stack 4 | 8 | 15 <- top")
        #expect("\(Stack(["x"]))" == "Stack x <- top")
    }

    @Test("Grows well past its initial capacity and empties in reverse order")
    func growth() {
        var stack = Stack<Int>()
        for value in 0..<100_000 {
            stack.push(value)
        }
        #expect(stack.count == 100_000)
        #expect(stack.peek() == 99_999)
        var expected = 99_999
        var mismatches = 0
        while let value = stack.pop() {
            if value != expected {
                mismatches += 1
            }
            expected -= 1
        }
        #expect(mismatches == 0)
        #expect(expected == -1)
        #expect(stack.isEmpty)
    }

    @Test("Copies are independent")
    func valueSemantics() {
        var original: Stack = [1, 2]
        var copy = original
        copy.push(3)
        original.pop()
        #expect(Array(original) == [1])
        #expect(Array(copy) == [3, 2, 1])
    }

    @Test("Equatable and Hashable when the elements are")
    func equatableAndHashable() {
        let first: Stack = [1, 2, 3]
        var second: Stack = [1, 2]
        #expect(first != second)
        second.push(3)
        #expect(first == second)
        #expect(Set([first, second]).count == 1)
        #expect(Stack([3, 2, 1]) != first)
    }

    @Test("removeAll empties it, and it can be reused")
    func removeAll() {
        var stack: Stack = [1, 2, 3]
        stack.removeAll(keepingCapacity: true)
        #expect(stack.isEmpty)
        stack.reserveCapacity(10)
        stack.push(7)
        #expect(Array(stack) == [7])
    }
}
