import Testing
import DSAKit

@Suite struct ElementarySortTests {
    /// A tiny deterministic generator, so the randomised tests do the same thing every run.
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

    /// The three sorts, so every test can run against each of them.
    enum Algorithm: String, CaseIterable, CustomStringConvertible {
        case bubble, selection, insertion

        var description: String { rawValue }

        var isStable: Bool { self != .selection }

        func sort<C: MutableCollection & RandomAccessCollection>(_ items: inout C) where C.Element: Comparable {
            switch self {
            case .bubble: items.bubbleSort()
            case .selection: items.selectionSort()
            case .insertion: items.insertionSort()
            }
        }

        func sort<C: MutableCollection & RandomAccessCollection>(
            _ items: inout C, by areInIncreasingOrder: (C.Element, C.Element) -> Bool
        ) {
            switch self {
            case .bubble: items.bubbleSort(by: areInIncreasingOrder)
            case .selection: items.selectionSort(by: areInIncreasingOrder)
            case .insertion: items.insertionSort(by: areInIncreasingOrder)
            }
        }
    }

    /// A record whose `key` is what gets sorted; `id` remembers the original position.
    struct Record: Equatable {
        let key: Int
        let id: Int
    }

    @Test("Empty and single-element collections", arguments: Algorithm.allCases)
    func tiny(algorithm: Algorithm) {
        var empty: [Int] = []
        algorithm.sort(&empty)
        #expect(empty == [])
        var single = [42]
        algorithm.sort(&single)
        #expect(single == [42])
        var emptySlice = [3, 1, 2][1..<1]
        algorithm.sort(&emptySlice)
        #expect(emptySlice.isEmpty)
    }

    @Test("Sorts small arrays", arguments: Algorithm.allCases)
    func small(algorithm: Algorithm) {
        let cases: [[Int]] = [
            [5, 1, 4, 2, 8, 3],
            [2, 1],
            [1, 2],
            [3, 3, 3, 3],
            [4, -2, 4, 0, -2, 7, 0],
            [Int.max, Int.min, 0, -1, 1],
        ]
        for numbers in cases {
            var copy = numbers
            algorithm.sort(&copy)
            #expect(copy == numbers.sorted(), "sorting \(numbers)")
        }
    }

    @Test("Sorted and reversed input", arguments: Algorithm.allCases)
    func sortedAndReversed(algorithm: Algorithm) {
        var ascending = Array(0..<200)
        algorithm.sort(&ascending)
        #expect(ascending == Array(0..<200))
        var descending = Array((0..<200).reversed())
        algorithm.sort(&descending)
        #expect(descending == Array(0..<200))
    }

    @Test("Sorts with a custom order", arguments: Algorithm.allCases)
    func customOrder(algorithm: Algorithm) {
        var scores = [5, 1, 4, 2, 8, 4]
        algorithm.sort(&scores, by: >)
        #expect(scores == [8, 5, 4, 4, 2, 1])
        var words = ["pear", "fig", "banana", "kiwi"]
        algorithm.sort(&words, by: { $0.count < $1.count })
        #expect(words.map(\.count) == [3, 4, 4, 6])
        var letters = ["d", "a", "c", "b"]
        algorithm.sort(&letters)
        #expect(letters == ["a", "b", "c", "d"])
    }

    @Test("Sorts a slice in place without touching the rest", arguments: Algorithm.allCases)
    func sliceOfArray(algorithm: Algorithm) {
        var numbers = [9, 8, 7, 6, 5, 4, 3]
        algorithm.sort(&numbers[2..<6])
        #expect(numbers == [9, 8, 4, 5, 6, 7, 3])
        algorithm.sort(&numbers[0..<2], by: >)
        #expect(numbers == [9, 8, 4, 5, 6, 7, 3])
        algorithm.sort(&numbers[5...])
        #expect(numbers == [9, 8, 4, 5, 6, 3, 7])
    }

    @Test("Sorts an ArraySlice whose indexes don't start at 0", arguments: Algorithm.allCases)
    func standaloneSlice(algorithm: Algorithm) {
        let numbers = [50, 40, 30, 20, 10, 0]
        var slice = numbers[3...]
        #expect(slice.startIndex == 3)
        algorithm.sort(&slice)
        #expect(Array(slice) == [0, 10, 20])
        #expect(slice.startIndex == 3)
        #expect(slice[3] == 0)
        #expect(numbers == [50, 40, 30, 20, 10, 0])     // the original array is a separate value
    }

    @Test("Sorts DSAKit's own collections", arguments: Algorithm.allCases)
    func dsaKitCollections(algorithm: Algorithm) {
        var deque: Deque = [4, 1, 3]
        deque.prepend(5)                                  // the front wraps round inside the ring
        algorithm.sort(&deque)
        #expect(Array(deque) == [1, 3, 4, 5])
        var dynamic: DynamicArray = ["pear", "fig", "apple"]
        algorithm.sort(&dynamic, by: >)
        #expect(Array(dynamic) == ["pear", "fig", "apple"])
        algorithm.sort(&dynamic)
        #expect(Array(dynamic) == ["apple", "fig", "pear"])
    }

    @Test("Sorts a ContiguousArray", arguments: Algorithm.allCases)
    func contiguousArray(algorithm: Algorithm) {
        var numbers: ContiguousArray = [3, 1, 2]
        algorithm.sort(&numbers)
        #expect(Array(numbers) == [1, 2, 3])
    }

    @Test("Bubble and insertion sort are stable", arguments: [Algorithm.bubble, .insertion])
    func stability(algorithm: Algorithm) {
        var steps = Steps(seed: 77)
        var records = (0..<300).map { Record(key: steps.next(below: 10), id: $0) }
        algorithm.sort(&records, by: { $0.key < $1.key })
        var stable = true
        for (left, right) in zip(records, records.dropFirst()) {
            if left.key > right.key || (left.key == right.key && left.id > right.id) {
                stable = false
            }
        }
        #expect(stable)
    }

    @Test("Stable sorts make two-pass sorting work", arguments: [Algorithm.bubble, .insertion])
    func twoPasses(algorithm: Algorithm) {
        // Sort by the second key, then by the first: ties on the first keep the second key's order
        var tasks = [("b", 2), ("a", 3), ("b", 1), ("a", 1), ("c", 2), ("a", 2)]
        algorithm.sort(&tasks, by: { $0.1 < $1.1 })
        algorithm.sort(&tasks, by: { $0.0 < $1.0 })
        #expect(tasks.map { "\($0.0)\($0.1)" } == ["a1", "a2", "a3", "b1", "b2", "c2"])
    }

    @Test("Selection sort is not stable")
    func selectionIsNotStable() {
        var records = [Record(key: 5, id: 0), Record(key: 5, id: 1), Record(key: 2, id: 2)]
        records.selectionSort(by: { $0.key < $1.key })
        // The first swap carries the 5 with id 0 past the other 5
        #expect(records.map(\.id) == [2, 1, 0])
    }

    @Test("Matches sorted() on hundreds of random arrays", arguments: Algorithm.allCases)
    func randomised(algorithm: Algorithm) {
        var steps = Steps(seed: 2_030)
        var firstFailure: [Int]? = nil
        for round in 0..<300 {
            let count = steps.next(below: 40)
            let spread = 1 + round % 25
            let numbers = (0..<count).map { _ in steps.next(below: spread) - spread / 2 }
            var copy = numbers
            algorithm.sort(&copy)
            if copy != numbers.sorted() {
                firstFailure = firstFailure ?? numbers
            }
        }
        #expect(firstFailure == nil, "the first array that wasn't sorted correctly")
    }

    @Test("Bubble sort stops early on sorted input")
    func bubbleEarlyExit() {
        var comparisons = 0
        var numbers = Array(0..<1_000)
        numbers.bubbleSort(by: { comparisons += 1; return $0 < $1 })
        #expect(comparisons == 999)
        #expect(numbers == Array(0..<1_000))
    }

    @Test("Selection sort makes every comparison, even on nearly sorted input")
    func selectionNotAdaptive() {
        // A 1,000-element array that's sorted except for one value at the wrong end
        var numbers = Array(1..<1_000) + [0]
        var comparisons = 0
        numbers.selectionSort(by: { comparisons += 1; return $0 < $1 })
        #expect(numbers == Array(0..<1_000))
        #expect(comparisons == 1_000 * 999 / 2)          // never adaptive
    }

    @Test("Insertion sort is fast on 100,000 nearly sorted values")
    func insertionNearlySorted() {
        // Every value is at most 3 places from where it belongs
        var numbers = Array(0..<100_000)
        for start in stride(from: 0, to: numbers.count - 3, by: 4) {
            numbers.swapAt(start, start + 3)
        }
        var comparisons = 0
        numbers.insertionSort(by: { comparisons += 1; return $0 < $1 })
        #expect(numbers == Array(0..<100_000))
        #expect(comparisons < 600_000)
    }
}
