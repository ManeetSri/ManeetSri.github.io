import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct SortedLookupTests {
    static let shelf = [2, 5, 8, 12, 16, 23, 38, 56, 72, 91]

    @Test("Finds values in the middle and at both ends", arguments: [
        (23, 5), (2, 0), (91, 9), (12, 3), (56, 7), (5, 1),
    ])
    func finds(target: Int, expected: Int) {
        #expect(SortedLookup.index(of: target, in: Self.shelf) == expected)
    }

    @Test("Reports values below, between and above as missing", arguments: [1, 7, 13, 90, 92, -100, 1_000])
    func missing(target: Int) {
        #expect(SortedLookup.index(of: target, in: Self.shelf) == nil)
    }

    @Test("Empty, one and two values")
    func tinyArrays() {
        #expect(SortedLookup.index(of: 4, in: []) == nil)
        #expect(SortedLookup.index(of: 4, in: [4]) == 0)
        #expect(SortedLookup.index(of: 3, in: [4]) == nil)
        #expect(SortedLookup.index(of: 5, in: [4]) == nil)
        #expect(SortedLookup.index(of: 4, in: [4, 9]) == 0)
        #expect(SortedLookup.index(of: 9, in: [4, 9]) == 1)
        #expect(SortedLookup.index(of: 6, in: [4, 9]) == nil)
        #expect(SortedLookup.index(of: 10, in: [4, 9]) == nil)
    }

    @Test("Negative numbers and the extremes of Int")
    func extremes() {
        let numbers = [Int.min, -50, -3, 0, 7, Int.max]
        #expect(SortedLookup.index(of: Int.min, in: numbers) == 0)
        #expect(SortedLookup.index(of: Int.max, in: numbers) == 5)
        #expect(SortedLookup.index(of: -3, in: numbers) == 2)
        #expect(SortedLookup.index(of: -4, in: numbers) == nil)
    }

    @Test("Every size from 0 to 12, every target present and absent")
    func exhaustive() {
        var firstMismatch: String? = nil
        for count in 0...12 {
            let numbers = (0..<count).map { $0 * 2 }            // 0, 2, 4, …
            for target in -1...(2 * count) {
                let expected = numbers.firstIndex(of: target)
                if SortedLookup.index(of: target, in: numbers) != expected {
                    firstMismatch = firstMismatch ?? "target \(target) in \(numbers)"
                }
            }
        }
        #expect(firstMismatch == nil, "the first input where the answer is wrong")
    }

    @Test("5,000 lookups in a million values")
    func large() {
        // -3,000,000, -2,999,994, … : a million values, 6 apart
        let numbers = Array(stride(from: -3_000_000, to: 3_000_000, by: 6))
        var wrong = 0
        for query in 0..<5_000 {
            let target = -3_000_007 + query * 1_201
            let offset = target + 3_000_000
            let expected = offset >= 0 && offset % 6 == 0 && offset / 6 < numbers.count ? offset / 6 : nil
            if SortedLookup.index(of: target, in: numbers) != expected {
                wrong += 1
            }
        }
        #expect(wrong == 0)
    }
}
