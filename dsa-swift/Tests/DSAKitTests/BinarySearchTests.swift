import Testing
import DSAKit

@Suite struct BinarySearchTests {
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

    // The models: plain linear scans that are obviously right
    private func modelLower(_ items: [Int], _ value: Int) -> Int {
        items.firstIndex { $0 >= value } ?? items.count
    }

    private func modelUpper(_ items: [Int], _ value: Int) -> Int {
        items.firstIndex { $0 > value } ?? items.count
    }

    // MARK: partitionPoint

    @Test("partitionPoint finds the first true")
    func partitionPointBasics() {
        let scores = [12, 31, 48, 50, 77, 91]
        #expect(scores.partitionPoint { $0 >= 50 } == 3)
        #expect(scores.partitionPoint { $0 >= 0 } == 0)
        #expect(scores.partitionPoint { $0 > 100 } == 6)
        #expect(scores.partitionPoint { $0 > 91 } == 6)
        #expect(scores.partitionPoint { $0 >= 91 } == 5)
    }

    @Test("partitionPoint on empty and single-element collections")
    func partitionPointSmall() {
        let empty: [Int] = []
        #expect(empty.partitionPoint { _ in true } == 0)
        #expect(empty.partitionPoint { _ in false } == 0)
        #expect([7].partitionPoint { $0 >= 7 } == 0)
        #expect([7].partitionPoint { $0 > 7 } == 1)
    }

    @Test("partitionPoint works for Bool predicates on other element types")
    func partitionPointStrings() {
        let words = ["apple", "banana", "cherry", "damson", "elder"]
        #expect(words.partitionPoint { $0 >= "c" } == 2)
        #expect(words.partitionPoint { $0.count > 100 } == 5)
    }

    @Test("partitionPoint asks O(log n) questions")
    func partitionPointCallCount() {
        let items = Array(0..<1_000_000)
        var calls = 0
        let point = items.partitionPoint { value in
            calls += 1
            return value >= 765_432
        }
        #expect(point == 765_432)
        #expect(calls <= 20)
    }

    @Test("partitionPoint rethrows the predicate's error")
    func partitionPointRethrows() {
        struct Stop: Error {}
        #expect(throws: Stop.self) {
            _ = try [1, 2, 3].partitionPoint { _ in throw Stop() }
        }
        // A predicate that doesn't throw needs no try
        #expect([1, 2, 3].partitionPoint { $0 > 1 } == 1)
    }

    // MARK: lowerBound and upperBound

    @Test("Bounds around a run of duplicates")
    func boundsWithDuplicates() {
        let sorted = [1, 3, 3, 3, 5, 8]
        #expect(sorted.lowerBound(of: 3) == 1)
        #expect(sorted.upperBound(of: 3) == 4)
        #expect(sorted.upperBound(of: 3) - sorted.lowerBound(of: 3) == 3)
        #expect(sorted.lowerBound(of: 1) == 0)
        #expect(sorted.upperBound(of: 8) == 6)
    }

    @Test("Absent values below, between and above", arguments: [
        (0, 0, 0),
        (2, 1, 1),
        (4, 4, 4),
        (7, 5, 5),
        (9, 6, 6),
        (Int.min, 0, 0),
        (Int.max, 6, 6),
    ])
    func absentValues(value: Int, lower: Int, upper: Int) {
        let sorted = [1, 3, 3, 3, 5, 8]
        #expect(sorted.lowerBound(of: value) == lower)
        #expect(sorted.upperBound(of: value) == upper)
        #expect(sorted.binarySearch(for: value) == nil)
    }

    @Test("Every element equal")
    func allEqual() {
        let same = Array(repeating: 4, count: 9)
        #expect(same.lowerBound(of: 4) == 0)
        #expect(same.upperBound(of: 4) == 9)
        #expect(same.binarySearch(for: 4) == 0)
        #expect(same.lowerBound(of: 5) == 9)
        #expect(same.upperBound(of: 3) == 0)
    }

    @Test("Empty and single-element collections")
    func smallCollections() {
        let empty: [Int] = []
        #expect(empty.lowerBound(of: 1) == 0)
        #expect(empty.upperBound(of: 1) == 0)
        #expect(empty.binarySearch(for: 1) == nil)

        let one = [5]
        #expect(one.lowerBound(of: 4) == 0)
        #expect(one.lowerBound(of: 5) == 0)
        #expect(one.lowerBound(of: 6) == 1)
        #expect(one.upperBound(of: 4) == 0)
        #expect(one.upperBound(of: 5) == 1)
        #expect(one.binarySearch(for: 5) == 0)
        #expect(one.binarySearch(for: 6) == nil)
    }

    // MARK: binarySearch

    @Test("binarySearch finds every element of a distinct array")
    func findsEveryElement() {
        let sorted = [2, 5, 8, 12, 16, 23, 38, 56, 72, 91]
        for (index, value) in sorted.enumerated() {
            #expect(sorted.binarySearch(for: value) == index)
        }
        #expect(sorted.binarySearch(for: 7) == nil)
        #expect(sorted.binarySearch(for: 1) == nil)
        #expect(sorted.binarySearch(for: 100) == nil)
    }

    @Test("binarySearch returns the first occurrence")
    func firstOccurrence() {
        let sorted = [2, 5, 5, 5, 5, 9]
        #expect(sorted.binarySearch(for: 5) == 1)
        #expect(sorted.binarySearch(for: 9) == 5)
        #expect(sorted.binarySearch(for: 2) == 0)
    }

    @Test("Strings and Doubles work too")
    func otherComparables() {
        let names = ["Ana", "Ben", "Cleo", "Dev"]
        #expect(names.binarySearch(for: "Cleo") == 2)
        #expect(names.binarySearch(for: "Bea") == nil)
        #expect(names.lowerBound(of: "Bea") == 1)
        let readings = [0.5, 1.25, 1.25, 3.0]
        #expect(readings.upperBound(of: 1.25) == 3)
    }

    // MARK: other index types

    @Test("Slices keep their parent's indexes")
    func slices() {
        let numbers = [0, 10, 20, 30, 30, 40, 50, 60]
        let middle = numbers[2..<7]                  // [20, 30, 30, 40, 50], indexes 2...6
        #expect(middle.lowerBound(of: 30) == 3)
        #expect(middle.upperBound(of: 30) == 5)
        #expect(middle.binarySearch(for: 40) == 5)
        #expect(middle.binarySearch(for: 10) == nil) // in the array, but not in the slice
        #expect(middle.lowerBound(of: 0) == 2)       // startIndex, not 0
        #expect(middle.lowerBound(of: 99) == 7)      // endIndex
        #expect(middle.partitionPoint { $0 > 45 } == 6)
        let emptySlice = numbers[4..<4]
        #expect(emptySlice.lowerBound(of: 30) == 4)
        #expect(emptySlice.binarySearch(for: 30) == nil)
    }

    @Test("Ranges, reversed collections and string views")
    func otherCollections() {
        let range = 10..<20
        #expect(range.lowerBound(of: 15) == 15)
        #expect(range.binarySearch(for: 25) == nil)
        #expect((0..<101).partitionPoint { $0 * $0 > 50 } == 8)

        // Reversed in decreasing order: a predicate that turns true at the right place still works
        let falling = [9, 7, 5, 3, 1].reversed()     // indexes aren't Ints
        let point = falling.partitionPoint { $0 >= 5 }
        #expect(falling[point] == 5)
        #expect(falling.binarySearch(for: 7).map { falling[$0] } == 7)

        let letters = Array("acegik")
        #expect(letters.lowerBound(of: "f") == 3)
    }

    // MARK: against a model

    @Test("Random sorted arrays match a linear scan")
    func matchesLinearModel() {
        var steps = Steps(seed: 2_024)
        var mismatches = 0
        for _ in 0..<2_000 {
            let count = steps.next(below: 20)
            let items = (0..<count).map { _ in steps.next(below: 10) }.sorted()
            for value in -1...10 {
                let lower = items.lowerBound(of: value)
                let upper = items.upperBound(of: value)
                if lower != modelLower(items, value) { mismatches += 1 }
                if upper != modelUpper(items, value) { mismatches += 1 }
                if items.binarySearch(for: value) != items.firstIndex(of: value) { mismatches += 1 }
            }
        }
        #expect(mismatches == 0)
    }

    @Test("Random slices match a linear scan")
    func slicesMatchLinearModel() {
        var steps = Steps(seed: 77)
        var mismatches = 0
        for _ in 0..<1_000 {
            let count = steps.next(below: 25) + 1
            let items = (0..<count).map { _ in steps.next(below: 12) }.sorted()
            let from = steps.next(below: count + 1)
            let to = from + steps.next(below: count - from + 1)
            let slice = items[from..<to]
            for value in -1...12 {
                let expectedLower = slice.firstIndex { $0 >= value } ?? slice.endIndex
                let expectedUpper = slice.firstIndex { $0 > value } ?? slice.endIndex
                if slice.lowerBound(of: value) != expectedLower { mismatches += 1 }
                if slice.upperBound(of: value) != expectedUpper { mismatches += 1 }
                if slice.binarySearch(for: value) != slice.firstIndex(of: value) { mismatches += 1 }
            }
        }
        #expect(mismatches == 0)
    }

    @Test("A million elements")
    func large() {
        let evens = Array(stride(from: 0, to: 2_000_000, by: 2))
        var mismatches = 0
        for value in stride(from: -3, to: 2_000_003, by: 997) {
            let expected = value < 0 ? 0 : min((value + 1) / 2, evens.count)
            if evens.lowerBound(of: value) != expected { mismatches += 1 }
            let found = evens.binarySearch(for: value)
            let shouldFind = value >= 0 && value < 2_000_000 && value % 2 == 0
            if (found != nil) != shouldFind || (found != nil && evens[found!] != value) { mismatches += 1 }
        }
        #expect(mismatches == 0)
    }
}
