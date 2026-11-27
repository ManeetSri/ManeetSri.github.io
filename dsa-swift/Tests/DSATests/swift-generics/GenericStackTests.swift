import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct GenericStackTests {
    typealias Stack = GenericStack.Stack

    private struct Plate: Equatable {
        var colour: String
    }

    @Test("A new stack is empty")
    func startsEmpty() {
        var stack = Stack<Int>()
        #expect(stack.isEmpty)
        #expect(stack.count == 0)
        #expect(stack.peek() == nil)
        #expect(stack.pop() == nil)
    }

    @Test("Last in, first out")
    func lastInFirstOut() {
        var stack = Stack<Int>()
        stack.push(1)
        stack.push(2)
        stack.push(3)
        #expect(stack.count == 3)
        #expect(!stack.isEmpty)
        #expect(stack.pop() == 3)
        #expect(stack.pop() == 2)
        #expect(stack.count == 1)
        #expect(stack.pop() == 1)
        #expect(stack.isEmpty)
        #expect(stack.pop() == nil)
    }

    @Test("peek looks without removing")
    func peek() {
        var stack = Stack<String>()
        stack.push("bottom")
        stack.push("top")
        #expect(stack.peek() == "top")
        #expect(stack.peek() == "top")
        #expect(stack.count == 2)
    }

    @Test("Pushes and pops can interleave")
    func interleaved() {
        var stack = Stack<Character>()
        stack.push("a")
        stack.push("b")
        #expect(stack.pop() == "b")
        stack.push("c")
        stack.push("d")
        #expect(stack.pop() == "d")
        #expect(stack.pop() == "c")
        #expect(stack.peek() == "a")
        #expect(stack.count == 1)
    }

    @Test("Works with your own types")
    func customElements() {
        var stack = Stack<Plate>()
        stack.push(Plate(colour: "white"))
        stack.push(Plate(colour: "blue"))
        #expect(stack.pop() == Plate(colour: "blue"))
        #expect(stack.peek() == Plate(colour: "white"))
    }

    @Test("Copies are independent")
    func valueSemantics() {
        var original = Stack<Int>()
        original.push(1)
        var copy = original
        copy.push(2)
        #expect(original.count == 1)
        #expect(copy.count == 2)
        #expect(original.peek() == 1)
    }

    @Test("Stays fast with 100,000 elements")
    func large() {
        var stack = Stack<Int>()
        for value in 0..<100_000 {
            stack.push(value)
        }
        #expect(stack.count == 100_000)
        var expected = 99_999
        var allInOrder = true
        while let value = stack.pop() {
            if value != expected { allInOrder = false }
            expected -= 1
        }
        #expect(allInOrder)
        #expect(expected == -1)
    }

    @Test("Applies edits with undo", arguments: [
        (["I", "love", "Swift"], "I love Swift"),
        (["I", "love", "Swift", "UNDO", "DSA"], "I love DSA"),
        (["one", "two", "UNDO", "UNDO", "three"], "three"),
        (["x", "y", "UNDO", "z", "UNDO", "UNDO", "w"], "w"),
        (["UNDO", "hello"], "hello"),
        (["a", "UNDO", "UNDO"], ""),
        ([], ""),
    ])
    func finalText(edits: [String], expected: String) {
        #expect(GenericStack.finalText(after: edits) == expected)
    }
}
