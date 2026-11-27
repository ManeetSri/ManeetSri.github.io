import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run builds the same lists
private struct NumberRangesRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct CompactNumberRangesTests {
    /// Brute force with a set: a value starts a run when the value before it is missing, and the run
    /// goes on while the next value is present. Neighbours are only formed when they exist.
    private func reference(_ values: [Int]) -> String {
        let present = Set(values)
        var parts: [String] = []
        for start in present.sorted() where start == Int.min || !present.contains(start - 1) {
            var end = start
            while end != Int.max && present.contains(end + 1) { end += 1 }
            if start == end { parts.append("\(start)") }
            else if end - 1 == start { parts.append("\(start), \(end)") }
            else { parts.append("\(start)...\(end)") }
        }
        return parts.joined(separator: ", ")
    }

    @Test("The statement's examples", arguments: [
        ([1, 2, 3, 5, 7, 8], "1...3, 5, 7, 8"),
        ([8, 3, 1, 2, 2, 7], "1...3, 7, 8"),
        ([-3, -1, -2, 1], "-3...-1, 1"),
        ([4], "4"),
        ([], ""),
        ([6, 6, 6], "6"),
        ([10, 12, 14], "10, 12, 14"),
        ([0, -1, 1], "-1...1"),
        ([1, 2, 3, 4, 5, 6, 7, 8, 9, 10], "1...10"),
    ])
    func examples(values: [Int], expected: String) {
        #expect(CompactNumberRanges.summary(values) == expected)
    }

    @Test("Runs of two are written as two values, runs of three or more as a range", arguments: [
        ([1, 2], "1, 2"),
        ([1, 2, 3], "1...3"),
        ([1, 2, 4, 5, 6], "1, 2, 4...6"),
        ([-2, -1], "-2, -1"),
        ([-1, 0, 2, 3], "-1, 0, 2, 3"),
    ])
    func runLengths(values: [Int], expected: String) {
        #expect(CompactNumberRanges.summary(values) == expected)
    }

    @Test("Duplicates and order don't matter", arguments: [
        ([3, 1, 2, 3, 1, 2], "1...3"),
        ([5, 5, 4, 4], "4, 5"),
        ([9, 9, 7, 7, 7], "7, 9"),
        ([2, 1, 2, 1, 2], "1, 2"),
    ])
    func duplicates(values: [Int], expected: String) {
        #expect(CompactNumberRanges.summary(values) == expected)
    }

    @Test("The ends of Int don't overflow")
    func extremes() {
        let max = Int.max, min = Int.min
        #expect(CompactNumberRanges.summary([max]) == "9223372036854775807")
        #expect(CompactNumberRanges.summary([max, max - 1]) == "9223372036854775806, 9223372036854775807")
        #expect(CompactNumberRanges.summary([max - 2, max, max - 1]) == "9223372036854775805...9223372036854775807")
        #expect(CompactNumberRanges.summary([min, min + 1, min + 2]) == "-9223372036854775808...-9223372036854775806")
        #expect(CompactNumberRanges.summary([min, max]) == "-9223372036854775808, 9223372036854775807")
        #expect(CompactNumberRanges.summary([max, min, 0]) == "-9223372036854775808, 0, 9223372036854775807")
        #expect(CompactNumberRanges.summary([min, min + 1]) == "-9223372036854775808, -9223372036854775807")
        #expect(CompactNumberRanges.summary([max, max, max]) == "9223372036854775807")
        #expect(CompactNumberRanges.summary([max - 1, max - 3, max]) == "9223372036854775804, 9223372036854775806, 9223372036854775807")
    }

    @Test("Matches a brute force on random lists, including values near the ends of Int")
    func randomLists() {
        var random = NumberRangesRandom(seed: 71)
        var firstMismatch: String? = nil
        for _ in 0..<1_000 where firstMismatch == nil {
            let count = Int.random(in: 0...10, using: &random)
            let values = (0..<count).map { _ -> Int in
                let small = Int.random(in: -4...4, using: &random)
                switch Int.random(in: 0..<6, using: &random) {
                case 0: return Int.max - Int.random(in: 0...3, using: &random)
                case 1: return Int.min + Int.random(in: 0...3, using: &random)
                default: return small
                }
            }
            let got = CompactNumberRanges.summary(values)
            let expected = reference(values)
            if got != expected {
                firstMismatch = "\(values): got \"\(got)\", expected \"\(expected)\""
            }
        }
        #expect(firstMismatch == nil)
    }

    @Test("350,000 values")
    func large() {
        // Blocks of 5 consecutive values with gaps of 2: 0...4, 6...10, ..., in a scrambled order,
        // each value twice
        let blocks = 50_000
        var values: [Int] = []
        for index in 0..<(blocks * 2) {
            let block = (index * 7_919) % blocks
            values.append(block * 6 + (index % 5))
        }
        for block in 0..<blocks {
            for offset in 0..<5 { values.append(block * 6 + offset) }
        }
        let expected = (0..<blocks).map { "\($0 * 6)...\($0 * 6 + 4)" }.joined(separator: ", ")
        #expect(CompactNumberRanges.summary(values) == expected)
    }
}
