import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct BuildDynamicArrayTests {
    typealias DynamicArray = BuildDynamicArray.DynamicArray

    private final class Token {
        init() {}
    }

    // Reads every element in order. Each test checks `count` first, so a stub fails without crashing.
    private func contents<Element>(of array: DynamicArray<Element>) -> [Element] {
        (0..<array.count).map { array[$0] }
    }

    private func make(_ values: [Int]) -> DynamicArray<Int> {
        var array = DynamicArray<Int>()
        for value in values {
            array.append(value)
        }
        return array
    }

    @Test("A new array is empty with capacity 0")
    func startsEmpty() {
        var array = DynamicArray<Int>()
        #expect(array.isEmpty)
        #expect(array.count == 0)
        #expect(array.capacity == 0)
        #expect(array.popLast() == nil)
    }

    @Test("Appending keeps the order")
    func appendKeepsOrder() throws {
        let array = make([5, 1, 4])
        try #require(array.count == 3)
        #expect(!array.isEmpty)
        #expect(contents(of: array) == [5, 1, 4])
    }

    @Test("Capacity doubles when the buffer is full")
    func doubling() {
        var array = DynamicArray<Int>()
        var capacities: [Int] = []
        for value in 1...9 {
            array.append(value)
            capacities.append(array.capacity)
        }
        #expect(capacities == [1, 2, 4, 4, 8, 8, 8, 8, 16])
        #expect(array.count == 9)
    }

    @Test("Subscripts read and write")
    func subscripts() throws {
        var array = make([10, 20, 30])
        try #require(array.count == 3)
        #expect(array[0] == 10)
        #expect(array[2] == 30)
        array[1] = 99
        array[2] += 1
        #expect(contents(of: array) == [10, 99, 31])
    }

    @Test("Inserting at the front, middle and end", arguments: [
        (0, [9, 1, 2, 3, 4]),
        (1, [1, 9, 2, 3, 4]),
        (2, [1, 2, 9, 3, 4]),
        (4, [1, 2, 3, 4, 9]),
    ])
    func insert(index: Int, expected: [Int]) throws {
        var array = make([1, 2, 3, 4])
        try #require(array.count == 4)
        array.insert(9, at: index)
        try #require(array.count == 5)
        #expect(contents(of: array) == expected)
        #expect(array.capacity == 8)
    }

    @Test("Inserting into an empty array, and growing on insert")
    func insertGrows() throws {
        var array = DynamicArray<String>()
        array.insert("b", at: 0)
        array.insert("a", at: 0)
        #expect(array.capacity == 2)
        array.insert("c", at: 2)
        #expect(array.capacity == 4)
        try #require(array.count == 3)
        #expect(contents(of: array) == ["a", "b", "c"])
    }

    @Test("Removing from the front, middle and end", arguments: [
        (0, 1, [2, 3, 4, 5]),
        (2, 3, [1, 2, 4, 5]),
        (4, 5, [1, 2, 3, 4]),
    ])
    func remove(index: Int, removed: Int, expected: [Int]) throws {
        var array = make([1, 2, 3, 4, 5])
        try #require(array.count == 5)
        #expect(array.remove(at: index) == removed)
        try #require(array.count == 4)
        #expect(contents(of: array) == expected)
        #expect(array.capacity == 8)
    }

    @Test("popLast removes from the end until empty")
    func popLast() {
        var array = make([1, 2, 3])
        #expect(array.popLast() == 3)
        #expect(array.popLast() == 2)
        #expect(array.count == 1)
        #expect(array.popLast() == 1)
        #expect(array.popLast() == nil)
        #expect(array.isEmpty)
    }

    @Test("Removing doesn't shrink, and the space is reused")
    func reuseAfterRemoving() throws {
        var array = make([1, 2, 3, 4])
        #expect(array.popLast() == 4)
        #expect(array.popLast() == 3)
        #expect(array.capacity == 4)
        array.append(7)
        array.append(8)
        #expect(array.capacity == 4)
        try #require(array.count == 4)
        #expect(contents(of: array) == [1, 2, 7, 8])
    }

    @Test("Removed elements are released")
    func releasesElements() throws {
        var array = DynamicArray<Token>()
        weak var first: Token?
        weak var last: Token?
        do {
            let a = Token()
            let b = Token()
            first = a
            last = b
            array.append(a)
            array.append(Token())
            array.append(b)
        }
        try #require(array.count == 3)
        _ = array.remove(at: 0)
        #expect(first == nil, "remove(at:) should let go of the removed element")
        _ = array.popLast()
        #expect(last == nil, "popLast() should let go of the removed element")
    }

    @Test("Copies are independent")
    func valueSemantics() throws {
        let original = make([1, 2, 3])
        var copy = original
        copy.append(4)
        try #require(copy.count == 4)
        copy[0] = 100
        try #require(original.count == 3)
        #expect(contents(of: original) == [1, 2, 3])
        #expect(contents(of: copy) == [100, 2, 3, 4])
    }

    @Test("Matches Array over a long mix of operations")
    func matchesArray() throws {
        var mine = DynamicArray<Int>()
        var reference: [Int] = []
        for step in 0..<3_000 {
            switch step % 6 {
            case 0, 1, 2:
                mine.append(step)
                reference.append(step)
            case 3:
                let index = (step * 31) % (reference.count + 1)
                mine.insert(-step, at: index)
                reference.insert(-step, at: index)
            case 4:
                if !reference.isEmpty && mine.count == reference.count {
                    let index = (step * 17) % reference.count
                    #expect(mine.remove(at: index) == reference.remove(at: index))
                }
            default:
                #expect(mine.popLast() == reference.popLast())
            }
            try #require(mine.count == reference.count, "count after step \(step)")
        }
        #expect(contents(of: mine) == reference)
    }

    @Test("100,000 appends stay fast")
    func large() throws {
        var array = DynamicArray<Int>()
        for value in 0..<100_000 {
            array.append(value)
        }
        try #require(array.count == 100_000)
        #expect(array.capacity == 131_072)
        #expect(array[0] == 0)
        #expect(array[99_999] == 99_999)
        var total = 0
        for index in 0..<array.count {
            total += array[index]
        }
        #expect(total == 4_999_950_000)
    }
}
