import Testing
import DSAKit

@Suite struct DynamicArrayTests {
    private final class Token {
        let id: Int
        init(id: Int) { self.id = id }
    }

    @Test("A new array is empty with no storage")
    func startsEmpty() {
        let numbers = DynamicArray<Int>()
        #expect(numbers.isEmpty)
        #expect(numbers.count == 0)
        #expect(numbers.capacity == 0)
        #expect(numbers.first == nil)
        #expect(numbers.last == nil)
        #expect(Array(numbers) == [])
        #expect(numbers.description == "[]")
    }

    @Test("A single element")
    func singleElement() {
        var numbers = DynamicArray<Int>()
        numbers.append(42)
        #expect(!numbers.isEmpty)
        #expect(numbers.count == 1)
        #expect(numbers.capacity == 1)
        #expect(numbers[0] == 42)
        #expect(numbers.first == 42)
        #expect(numbers.last == 42)
    }

    @Test("Capacity doubles when the buffer is full")
    func doubling() {
        var numbers = DynamicArray<Int>()
        var capacities: [Int] = []
        for value in 1...9 {
            numbers.append(value)
            capacities.append(numbers.capacity)
        }
        #expect(capacities == [1, 2, 4, 4, 8, 8, 8, 8, 16])
        #expect(Array(numbers) == Array(1...9))
    }

    @Test("Appends keep their order across many growths")
    func orderAcrossGrowth() {
        var numbers = DynamicArray<Int>()
        for value in 0..<1_000 {
            numbers.append(value * 3)
        }
        #expect(numbers.count == 1_000)
        #expect(numbers.capacity == 1_024)
        #expect(numbers.elementsEqual((0..<1_000).map { $0 * 3 }))
    }

    @Test("A reserved capacity is used before growing")
    func reserved() {
        var numbers = DynamicArray<Int>(minimumCapacity: 5)
        #expect(numbers.capacity == 5)
        #expect(numbers.isEmpty)
        for value in 1...5 {
            numbers.append(value)
        }
        #expect(numbers.capacity == 5)
        numbers.append(6)
        #expect(numbers.capacity == 10)

        numbers.reserveCapacity(4)
        #expect(numbers.capacity == 10)
        numbers.reserveCapacity(50)
        #expect(numbers.capacity == 50)
        #expect(Array(numbers) == [1, 2, 3, 4, 5, 6])
    }

    @Test("Subscripts read and write", arguments: [0, 2, 4])
    func subscripts(index: Int) {
        var numbers: DynamicArray = [10, 20, 30, 40, 50]
        numbers[index] = -1
        #expect(numbers[index] == -1)
        #expect(numbers.count == 5)
        #expect(numbers.filter { $0 == -1 }.count == 1)
    }

    @Test("Inserting at the front, middle and end", arguments: [
        (0, [9, 1, 2, 3, 4]),
        (2, [1, 2, 9, 3, 4]),
        (4, [1, 2, 3, 4, 9]),
    ])
    func insert(index: Int, expected: [Int]) {
        var numbers: DynamicArray = [1, 2, 3, 4]
        numbers.insert(9, at: index)
        #expect(Array(numbers) == expected)
        #expect(numbers.count == 5)
    }

    @Test("Inserting into a full buffer grows it")
    func insertGrows() {
        var numbers = DynamicArray<Int>()
        numbers.insert(2, at: 0)
        numbers.insert(1, at: 0)
        #expect(numbers.capacity == 2)
        numbers.insert(3, at: 2)
        #expect(numbers.capacity == 4)
        #expect(Array(numbers) == [1, 2, 3])
    }

    @Test("Removing from the front, middle and end", arguments: [
        (0, 1, [2, 3, 4, 5]),
        (2, 3, [1, 2, 4, 5]),
        (4, 5, [1, 2, 3, 4]),
    ])
    func remove(index: Int, removed: Int, expected: [Int]) {
        var numbers: DynamicArray = [1, 2, 3, 4, 5]
        let capacityBefore = numbers.capacity
        #expect(numbers.remove(at: index) == removed)
        #expect(Array(numbers) == expected)
        #expect(numbers.capacity == capacityBefore)
    }

    @Test("Removing the only element leaves an empty array")
    func removeOnly() {
        var words: DynamicArray = ["solo"]
        #expect(words.remove(at: 0) == "solo")
        #expect(words.isEmpty)
        words.append("again")
        #expect(Array(words) == ["again"])
    }

    @Test("removeLast and popLast")
    func removeLast() {
        var numbers: DynamicArray = [1, 2, 3]
        #expect(numbers.removeLast() == 3)
        #expect(numbers.popLast() == 2)
        #expect(numbers.popLast() == 1)
        #expect(numbers.popLast() == nil)
        #expect(numbers.isEmpty)
        #expect(numbers.capacity == 3)
    }

    @Test("Removed elements are released")
    func releasesElements() {
        var tokens = DynamicArray<Token>()
        weak var watched: Token?
        do {
            let token = Token(id: 1)
            watched = token
            tokens.append(token)
            tokens.append(Token(id: 2))
        }
        #expect(watched != nil)
        _ = tokens.remove(at: 0)
        #expect(watched == nil)
        #expect(tokens.count == 1)
        #expect(tokens[0].id == 2)
    }

    @Test("removeAll can keep or drop the buffer")
    func removeAll() {
        var numbers: DynamicArray = [1, 2, 3, 4, 5]
        numbers.removeAll(keepingCapacity: true)
        #expect(numbers.isEmpty)
        #expect(numbers.capacity == 5)
        numbers.append(7)
        #expect(Array(numbers) == [7])
        numbers.removeAll()
        #expect(numbers.isEmpty)
        #expect(numbers.capacity == 0)
    }

    @Test("Interleaved operations match Array")
    func matchesArray() {
        var mine = DynamicArray<Int>()
        var reference: [Int] = []
        for step in 0..<2_000 {
            switch step % 7 {
            case 0, 1, 2:
                mine.append(step)
                reference.append(step)
            case 3:
                let index = reference.isEmpty ? 0 : (step * 31) % (reference.count + 1)
                mine.insert(-step, at: index)
                reference.insert(-step, at: index)
            case 4:
                if !reference.isEmpty {
                    let index = (step * 17) % reference.count
                    #expect(mine.remove(at: index) == reference.remove(at: index))
                }
            case 5:
                #expect(mine.popLast() == reference.popLast())
            default:
                if !reference.isEmpty {
                    let index = (step * 13) % reference.count
                    mine[index] += 1
                    reference[index] += 1
                }
            }
        }
        #expect(Array(mine) == reference)
        #expect(mine.count == reference.count)
    }

    @Test("Array literals, sequences and descriptions")
    func literalsAndDescription() {
        let numbers: DynamicArray = [3, 1, 2]
        #expect(numbers.description == "[3, 1, 2]")
        #expect("\(numbers)" == "[3, 1, 2]")
        let words: DynamicArray = ["a", "b"]
        #expect(words.description == "[\"a\", \"b\"]")
        let fromRange = DynamicArray(1...4)
        #expect(Array(fromRange) == [1, 2, 3, 4])
        var appended = DynamicArray<Int>()
        appended.append(contentsOf: [5, 6, 7])
        #expect(appended == [5, 6, 7])
    }

    @Test("Works with Collection algorithms")
    func collectionAlgorithms() {
        var numbers: DynamicArray = [5, 3, 8, 1, 9, 2]
        #expect(numbers.map { $0 * 2 } == [10, 6, 16, 2, 18, 4])
        #expect(numbers.reduce(0, +) == 28)
        #expect(numbers.firstIndex(of: 8) == 2)
        #expect(numbers.max() == 9)
        #expect(Array(numbers.reversed()) == [2, 9, 1, 8, 3, 5])
        #expect(Array(numbers[1..<3]) == [3, 8])
        #expect(numbers.indices == 0..<6)
        numbers.swapAt(0, 5)
        #expect(numbers == [2, 3, 8, 1, 9, 5])
        numbers.sort()
        #expect(numbers == [1, 2, 3, 5, 8, 9])
        numbers.reverse()
        #expect(numbers == [9, 8, 5, 3, 2, 1])
        var total = 0
        for value in numbers {
            total += value
        }
        #expect(total == 28)
    }

    @Test("Equality ignores capacity")
    func equality() {
        var roomy = DynamicArray<Int>(minimumCapacity: 100)
        roomy.append(contentsOf: [1, 2])
        let snug: DynamicArray = [1, 2]
        #expect(roomy == snug)
        #expect(roomy != [2, 1])
        #expect(roomy != [1, 2, 3])
    }

    @Test("Copies are independent")
    func valueSemantics() {
        var original: DynamicArray = [1, 2, 3]
        var copy = original
        copy.append(4)
        copy[0] = 100
        #expect(original == [1, 2, 3])
        #expect(copy == [100, 2, 3, 4])
        original.removeLast()
        #expect(copy.count == 4)
    }

    @Test("100,000 appends stay fast")
    func large() {
        var numbers = DynamicArray<Int>()
        for value in 0..<100_000 {
            numbers.append(value)
        }
        #expect(numbers.count == 100_000)
        #expect(numbers.capacity == 131_072)
        #expect(numbers[99_999] == 99_999)
        #expect(numbers.reduce(0, +) == 4_999_950_000)
        while numbers.count > 50_000 {
            numbers.removeLast()
        }
        #expect(numbers.last == 49_999)
    }
}
