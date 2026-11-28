import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct KeepValidNumbersTests {
    @Test("Keeps valid numbers from every row, in order")
    func normalRows() {
        let rows = [["12", "seven", "5"], ["", "40"], ["-3", "x"]]
        #expect(KeepValidNumbers.validNumbers(in: rows) == [12, 5, 40, -3])
    }

    @Test("Follows Int's own rules for what counts as a number", arguments: [
        ("+4", [4]),
        ("-0", [0]),
        ("007", [7]),
        ("4.5", []),
        (" 5", []),
        ("5 ", []),
        ("1,000", []),
        ("", []),
        ("--2", []),
    ])
    func intRules(entry: String, expected: [Int]) {
        #expect(KeepValidNumbers.validNumbers(in: [[entry]]) == expected)
    }

    @Test("Empty input and empty rows give an empty result")
    func empty() {
        #expect(KeepValidNumbers.validNumbers(in: []) == [])
        #expect(KeepValidNumbers.validNumbers(in: [[], [], []]) == [])
    }

    @Test("Rows with no valid numbers are skipped")
    func noValid() {
        #expect(KeepValidNumbers.validNumbers(in: [["a", "b"], ["c"]]) == [])
        #expect(KeepValidNumbers.validNumbers(in: [["a"], ["9"], ["b"]]) == [9])
    }

    @Test("Keeps duplicates")
    func duplicates() {
        #expect(KeepValidNumbers.validNumbers(in: [["1", "1"], ["1"]]) == [1, 1, 1])
    }

    @Test("Handles the extremes of Int")
    func extremes() {
        let rows = [["9223372036854775807", "-9223372036854775808"], ["9223372036854775808"]]
        #expect(KeepValidNumbers.validNumbers(in: rows) == [Int.max, Int.min])
    }

    @Test("Stays fast on 100,000 entries")
    func large() {
        let rows = (0..<1_000).map { row in (0..<100).map { column in column % 2 == 0 ? "\(row * 100 + column)" : "n/a" } }
        let result = KeepValidNumbers.validNumbers(in: rows)
        #expect(result.count == 50_000)
        #expect(result.first == 0)
        #expect(result.last == 99_998)
    }
}
