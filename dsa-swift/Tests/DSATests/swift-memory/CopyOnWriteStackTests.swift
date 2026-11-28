import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct CopyOnWriteStackTests {
    typealias Stack = CopyOnWriteStack.Stack

    @Test("Pushes and pops in last-in, first-out order")
    func lifo() {
        var stack = Stack()
        #expect(stack.isEmpty)
        stack.push(1)
        stack.push(2)
        stack.push(3)
        #expect(stack.count == 3)
        #expect(!stack.isEmpty)
        #expect(stack.top == 3)
        #expect(stack.elements == [1, 2, 3])
        #expect(stack.pop() == 3)
        #expect(stack.pop() == 2)
        #expect(stack.pop() == 1)
        #expect(stack.pop() == nil)
        #expect(stack.isEmpty)
        #expect(stack.top == nil)
    }

    @Test("Starts from an array with the last element on top")
    func fromArray() {
        let stack = Stack([4, 5, 6])
        #expect(stack.elements == [4, 5, 6])
        #expect(stack.top == 6)
        #expect(stack.count == 3)
    }

    @Test("A copy shares storage until something changes")
    func copiesShare() {
        let original = Stack([1, 2])
        let copy = original
        #expect(original.isSharingStorage(with: copy))
        #expect(copy.elements == [1, 2])
        #expect(original.isSharingStorage(with: copy), "Reading must not copy the storage")
    }

    @Test("Separately created stacks never share storage")
    func separateStacks() {
        let first = Stack([1, 2])
        let second = Stack([1, 2])
        #expect(!first.isSharingStorage(with: second))
    }

    @Test("Pushing onto a copy leaves the original alone")
    func pushOnCopy() {
        let original = Stack([1, 2])
        var copy = original
        copy.push(3)
        #expect(!original.isSharingStorage(with: copy))
        #expect(original.elements == [1, 2])
        #expect(copy.elements == [1, 2, 3])
    }

    @Test("Popping from a copy leaves the original alone")
    func popOnCopy() {
        let original = Stack([1, 2, 3])
        var copy = original
        #expect(copy.pop() == 3)
        #expect(original.elements == [1, 2, 3])
        #expect(copy.elements == [1, 2])
    }

    @Test("Clearing a copy leaves the original alone")
    func removeAllOnCopy() {
        let original = Stack([1, 2, 3])
        var copy = original
        copy.removeAll()
        #expect(copy.isEmpty)
        #expect(original.elements == [1, 2, 3])
    }

    @Test("Changing the original leaves the copy alone")
    func changeOriginal() {
        var original = Stack([7])
        let copy = original
        original.push(8)
        #expect(original.elements == [7, 8])
        #expect(copy.elements == [7])
    }

    @Test("A stack that isn't shared changes in place")
    func uniqueChangesInPlace() {
        var stack = Stack([1])
        let before = stack.storageID
        stack.push(2)
        #expect(stack.storageID == before, "push copied storage that wasn't shared")
        _ = stack.pop()
        #expect(stack.storageID == before, "pop copied storage that wasn't shared")
        stack.removeAll()
        #expect(stack.storageID == before, "removeAll copied storage that wasn't shared")
    }

    @Test("After one copy, both stacks change in place")
    func copyOnlyOnce() {
        var first = Stack([1, 2])
        var second = first
        second.push(3)                  // the one real copy
        let firstID = first.storageID
        let secondID = second.storageID
        second.push(4)
        first.push(5)
        #expect(second.storageID == secondID)
        #expect(first.storageID == firstID)
        #expect(first.elements == [1, 2, 5])
        #expect(second.elements == [1, 2, 3, 4])
    }

    @Test("Many pushes and pops")
    func manyOperations() {
        var stack = Stack()
        for value in 0..<10_000 {
            stack.push(value)
        }
        let snapshot = stack
        var total = 0
        while let value = stack.pop() {
            total += value
        }
        #expect(total == 49_995_000)
        #expect(stack.isEmpty)
        #expect(snapshot.count == 10_000)
        #expect(snapshot.top == 9_999)
    }
}
