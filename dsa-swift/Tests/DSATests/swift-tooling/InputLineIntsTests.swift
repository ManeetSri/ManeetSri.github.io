import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct InputLineIntsTests {
    @Test("Reads the integers on a line", arguments: [
        ("3 9 4", [3, 9, 4]),
        ("42", [42]),
        ("-5 0 12", [-5, 0, 12]),
        ("  7   8  ", [7, 8]),
        ("1\t2 \t3", [1, 2, 3]),
        ("+6 -0", [6, 0]),
    ])
    func readsIntegers(line: String, expected: [Int]) {
        #expect(InputLineInts.integers(in: line) == expected)
    }

    @Test("A line with no numbers gives an empty array", arguments: ["", "   ", "\t"])
    func blankLine(line: String) {
        #expect(InputLineInts.integers(in: line) == [])
    }

    @Test("Any piece that isn't a whole number gives nil", arguments: [
        "1 two 3",
        "4.5",
        "12a",
        "1,2",
        "- 5",
        "99999999999999999999",
    ])
    func rejectsBadPieces(line: String) {
        #expect(InputLineInts.integers(in: line) == nil)
    }

    @Test("Handles the largest and smallest Int")
    func extremes() {
        #expect(InputLineInts.integers(in: "9223372036854775807 -9223372036854775808") == [Int.max, Int.min])
    }

    @Test("Reads a count and then that many numbers")
    func readsArray() {
        #expect(InputLineInts.readArray(from: ["3", "10 20 30"]) == [10, 20, 30])
        #expect(InputLineInts.readArray(from: [" 2 ", "-1  -2"]) == [-1, -2])
        #expect(InputLineInts.readArray(from: ["1", "5", "these lines", "are ignored"]) == [5])
    }

    @Test("A count of zero allows a missing or blank second line")
    func zeroCount() {
        #expect(InputLineInts.readArray(from: ["0"]) == [])
        #expect(InputLineInts.readArray(from: ["0", ""]) == [])
        #expect(InputLineInts.readArray(from: ["0", "4"]) == nil)
    }

    @Test("Input that doesn't match the format gives nil", arguments: [
        [],
        ["three", "1 2 3"],
        ["3", "1 2"],
        ["2", "1 2 3"],
        ["2"],
        ["2", "1 x"],
        ["-1", ""],
        ["1 2", "3"],
        [""],
    ])
    func rejectsBadFormat(lines: [String]) {
        #expect(InputLineInts.readArray(from: lines) == nil)
    }

    @Test("Reads a long line")
    func longLine() {
        let numbers = (1...50_000).map { $0 * 3 - 70_000 }
        let line = numbers.map(String.init).joined(separator: " ")
        #expect(InputLineInts.integers(in: line) == numbers)
        #expect(InputLineInts.readArray(from: ["50000", line]) == numbers)
    }
}
