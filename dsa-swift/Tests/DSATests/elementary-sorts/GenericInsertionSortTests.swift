import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct GenericInsertionSortTests {
    /// A tiny deterministic generator, so the randomised tests do the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    /// A record sorted by `key`; `id` remembers where it started.
    struct Entry: Equatable {
        let key: Int
        let id: Int
    }

    @Test("Sorts arrays of numbers")
    func numbers() {
        var numbers = [3, 1, 2]
        GenericInsertionSort.sort(&numbers, by: <)
        #expect(numbers == [1, 2, 3])
        var mixed = [5, -1, 4, 4, 0, -7]
        GenericInsertionSort.sort(&mixed, by: <)
        #expect(mixed == [-7, -1, 0, 4, 4, 5])
        GenericInsertionSort.sort(&mixed, by: >)
        #expect(mixed == [5, 4, 4, 0, -1, -7])
    }

    @Test("Empty and single-element collections")
    func tiny() {
        var empty: [Int] = []
        GenericInsertionSort.sort(&empty, by: <)
        #expect(empty == [])
        var single = ["only"]
        GenericInsertionSort.sort(&single, by: <)
        #expect(single == ["only"])
        var numbers = [3, 2, 1]
        GenericInsertionSort.sort(&numbers[1..<1], by: <)
        #expect(numbers == [3, 2, 1])
    }

    @Test("Is stable: equal keys keep their order")
    func stable() {
        var words = ["pear", "fig", "kiwi", "plum", "date", "apple"]
        GenericInsertionSort.sort(&words) { $0.count < $1.count }
        #expect(words == ["fig", "pear", "kiwi", "plum", "date", "apple"])
    }

    @Test("Sorts part of an array in place")
    func middleOfArray() {
        var numbers = [9, 8, 7, 6, 5]
        GenericInsertionSort.sort(&numbers[1..<4], by: <)
        #expect(numbers == [9, 6, 7, 8, 5])
        GenericInsertionSort.sort(&numbers[3...], by: <)
        #expect(numbers == [9, 6, 7, 5, 8])
    }

    @Test("Sorts a slice whose indexes don't start at 0")
    func standaloneSlice() {
        var tail = [5, 4, 3, 2][2...]
        GenericInsertionSort.sort(&tail, by: <)
        #expect(Array(tail) == [2, 3])
        #expect(tail.startIndex == 2)
        #expect(tail[2] == 2)
        var longer = [50, 40, 30, 20, 10, 0][1...4]
        GenericInsertionSort.sort(&longer, by: <)
        #expect(Array(longer) == [10, 20, 30, 40])
    }

    @Test("Sorts a ContiguousArray")
    func contiguousArray() {
        var letters: ContiguousArray = ["c", "a", "b"]
        GenericInsertionSort.sort(&letters, by: <)
        #expect(Array(letters) == ["a", "b", "c"])
    }

    @Test("Matches the standard library's stable sort on hundreds of random arrays")
    func randomised() {
        var steps = Steps(seed: 10)
        var mismatches = 0
        for _ in 0..<300 {
            let entries = (0..<steps.next(below: 40)).map { Entry(key: steps.next(below: 8), id: $0) }
            var copy = entries
            GenericInsertionSort.sort(&copy) { $0.key < $1.key }
            // sorted(by:) is guaranteed stable, so a correct stable sort gives exactly the same order
            if copy != entries.sorted(by: { $0.key < $1.key }) { mismatches += 1 }
        }
        #expect(mismatches == 0)
    }

    @Test("Sorts random slices of a larger array")
    func randomSlices() {
        var steps = Steps(seed: 11)
        var mismatches = 0
        for _ in 0..<200 {
            let numbers = (0..<30).map { _ in steps.next(below: 100) }
            let low = steps.next(below: 30)
            let high = low + steps.next(below: 31 - low)
            var copy = numbers
            GenericInsertionSort.sort(&copy[low..<high], by: <)
            let expected = Array(numbers[..<low]) + numbers[low..<high].sorted() + Array(numbers[high...])
            if copy != expected { mismatches += 1 }
        }
        #expect(mismatches == 0)
    }

    @Test("Is fast on 100,000 values that are nearly sorted")
    func largeNearlySorted() {
        var numbers = Array(0..<100_000)
        for start in stride(from: 0, to: 99_990, by: 10) {
            numbers.swapAt(start, start + 1)
        }
        GenericInsertionSort.sort(&numbers, by: <)
        #expect(numbers == Array(0..<100_000))
    }
}
