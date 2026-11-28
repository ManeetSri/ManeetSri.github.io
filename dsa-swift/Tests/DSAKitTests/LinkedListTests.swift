import Testing
import DSAKit

@Suite struct LinkedListTests {
    @Test("A new list is empty")
    func empty() {
        let list = LinkedList<Int>()
        #expect(list.isEmpty)
        #expect(list.count == 0)
        #expect(list.first == nil)
        #expect(list.last == nil)
        #expect(Array(list) == [])
        #expect(list.description == "nil")
    }

    @Test("append adds to the end and prepend to the front")
    func appendPrepend() {
        var list = LinkedList<Int>()
        list.append(2)
        list.append(3)
        list.prepend(1)
        list.prepend(0)
        #expect(Array(list) == [0, 1, 2, 3])
        #expect(list.first == 0)
        #expect(list.last == 3)
        #expect(list.count == 4)
    }

    @Test("prepend on an empty list sets the last element too")
    func prependEmpty() {
        var list = LinkedList<String>()
        list.prepend("only")
        #expect(list.first == "only")
        #expect(list.last == "only")
        list.append("after")
        #expect(Array(list) == ["only", "after"])
    }

    @Test("insert(_:at:) puts the value at that position", arguments: [
        (0, [9, 1, 2, 3]),
        (1, [1, 9, 2, 3]),
        (2, [1, 2, 9, 3]),
        (3, [1, 2, 3, 9]),
    ])
    func insert(index: Int, expected: [Int]) {
        var list: LinkedList = [1, 2, 3]
        list.insert(9, at: index)
        #expect(Array(list) == expected)
        #expect(list.count == 4)
        #expect(list.last == expected.last)
        list.append(100)
        #expect(Array(list) == expected + [100])
    }

    @Test("remove(at:) returns the value and keeps the tail right", arguments: [
        (0, 1, [2, 3]),
        (1, 2, [1, 3]),
        (2, 3, [1, 2]),
    ])
    func remove(index: Int, removed: Int, expected: [Int]) {
        var list: LinkedList = [1, 2, 3]
        #expect(list.remove(at: index) == removed)
        #expect(Array(list) == expected)
        #expect(list.count == 2)
        #expect(list.last == expected.last)
        list.append(4)
        #expect(Array(list) == expected + [4])
    }

    @Test("Removing the only element leaves an empty list that still works")
    func removeOnly() {
        var list: LinkedList = [5]
        #expect(list.remove(at: 0) == 5)
        #expect(list.isEmpty)
        #expect(list.last == nil)
        list.append(6)
        #expect(Array(list) == [6])
        #expect(list.first == 6 && list.last == 6)
    }

    @Test("removeFirst and popFirst take from the front")
    func removeFirst() {
        var list: LinkedList = ["a", "b"]
        #expect(list.removeFirst() == "a")
        #expect(list.popFirst() == "b")
        #expect(list.popFirst() == nil)
        #expect(list.isEmpty)
        #expect(list.last == nil)
        list.append("c")
        #expect(Array(list) == ["c"])
    }

    @Test("removeAll empties the list")
    func removeAll() {
        var list: LinkedList = [1, 2, 3]
        list.removeAll()
        #expect(list.isEmpty && list.count == 0 && list.last == nil)
        list.append(4)
        #expect(Array(list) == [4])
    }

    @Test("element(at:) and firstIndex(of:) search the list")
    func search() {
        let list: LinkedList = [4, 8, 15, 16, 8]
        #expect(list.element(at: 0) == 4)
        #expect(list.element(at: 4) == 8)
        #expect(list.element(at: 5) == nil)
        #expect(list.element(at: -1) == nil)
        #expect(list.firstIndex(of: 8) == 1)
        #expect(list.firstIndex(of: 42) == nil)
        #expect(list.contains(16))
    }

    @Test("reverse turns the list around and fixes first and last", arguments: [
        [Int](),
        [1],
        [1, 2],
        [1, 2, 3, 4, 5],
    ])
    func reverse(values: [Int]) {
        var list = LinkedList(values)
        list.reverse()
        #expect(Array(list) == values.reversed())
        #expect(list.first == values.last)
        #expect(list.last == values.first)
        list.append(99)
        #expect(Array(list) == values.reversed() + [99])
    }

    @Test("It's a Sequence, so for-in and the Sequence methods work")
    func sequence() {
        let list: LinkedList = [3, 1, 4, 1, 5]
        var seen: [Int] = []
        for value in list {
            seen.append(value)
        }
        #expect(seen == [3, 1, 4, 1, 5])
        #expect(list.map { $0 * 2 } == [6, 2, 8, 2, 10])
        #expect(list.reduce(0, +) == 14)
        #expect(list.max() == 5)
        #expect(Array(list) == Array(list), "a second pass starts again from the head")
    }

    @Test("Array literals, init from a sequence, and description")
    func literalsAndDescription() {
        let list: LinkedList = [1, 2, 3]
        #expect(list.description == "1 -> 2 -> 3 -> nil")
        #expect(LinkedList(1...4).description == "1 -> 2 -> 3 -> 4 -> nil")
        let words: LinkedList = ["a", "b"]
        #expect(words.description == "a -> b -> nil")
    }

    @Test("Equal lists compare equal")
    func equatable() {
        let a: LinkedList = [1, 2, 3]
        var b = LinkedList<Int>()
        b.append(1)
        b.append(2)
        b.append(3)
        #expect(a == b)
        b.append(4)
        #expect(a != b)
        #expect(LinkedList<Int>() == LinkedList<Int>())
    }

    @Test("Copies are independent: changing one never changes another")
    func valueSemantics() {
        let original: LinkedList = [1, 2, 3]
        var appended = original
        appended.append(4)
        var prepended = original
        prepended.prepend(0)
        var inserted = original
        inserted.insert(9, at: 1)
        var removed = original
        removed.remove(at: 2)
        var popped = original
        _ = popped.popFirst()
        var reversed = original
        reversed.reverse()
        var cleared = original
        cleared.removeAll()

        #expect(Array(original) == [1, 2, 3])
        #expect(original.count == 3 && original.last == 3)
        #expect(Array(appended) == [1, 2, 3, 4])
        #expect(Array(prepended) == [0, 1, 2, 3])
        #expect(Array(inserted) == [1, 9, 2, 3])
        #expect(Array(removed) == [1, 2])
        #expect(Array(popped) == [2, 3])
        #expect(Array(reversed) == [3, 2, 1])
        #expect(cleared.isEmpty)
    }

    @Test("Changing a list inside a loop over it doesn't change the loop")
    func mutateWhileIterating() {
        var list: LinkedList = [1, 2, 3]
        for value in list {
            list.append(value * 10)
        }
        #expect(Array(list) == [1, 2, 3, 10, 20, 30])
    }

    @Test("Grows to 100,000 elements with O(1) appends and prepends")
    func large() {
        var list = LinkedList<Int>()
        for value in 0..<50_000 {
            list.append(value)
        }
        for value in 1...50_000 {
            list.prepend(-value)
        }
        #expect(list.count == 100_000)
        #expect(list.first == -50_000)
        #expect(list.last == 49_999)
        #expect(list.reduce(0, +) == -50_000)
        var copy = list
        copy.reverse()
        #expect(copy.first == 49_999 && list.first == -50_000)
        while list.popFirst() != nil {}
        #expect(list.isEmpty)
    }
}
