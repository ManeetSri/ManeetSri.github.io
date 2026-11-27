import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct CheckedSubarraySumTests {
    typealias RangeError = CheckedSubarraySum.RangeError

    private let numbers = [4, -2, 7, 1, 9]

    @Test("Sums valid windows", arguments: [
        (0, 2, 2),
        (1, 3, 6),
        (0, 5, 19),
        (4, 1, 9),
        (2, 0, 0),
    ])
    func sumsWindows(start: Int, length: Int, expected: Int) throws {
        #expect(try CheckedSubarraySum.sum(of: numbers, from: start, length: length) == expected)
    }

    @Test("An empty window at the very end is allowed")
    func emptyAtEnd() throws {
        #expect(try CheckedSubarraySum.sum(of: numbers, from: 5, length: 0) == 0)
        #expect(try CheckedSubarraySum.sum(of: [], from: 0, length: 0) == 0)
    }

    @Test("A negative length is rejected", arguments: [-1, -5, Int.min])
    func negativeLength(length: Int) {
        #expect(throws: RangeError.negativeLength(length)) {
            try CheckedSubarraySum.sum(of: numbers, from: 0, length: length)
        }
    }

    @Test("A start outside the array is rejected", arguments: [-1, 6, 100, Int.min])
    func startOutOfBounds(start: Int) {
        #expect(throws: RangeError.startOutOfBounds(start)) {
            try CheckedSubarraySum.sum(of: numbers, from: start, length: 1)
        }
    }

    @Test("A window that runs past the end is rejected", arguments: [
        (0, 6, 5),
        (3, 3, 2),
        (5, 1, 0),
    ])
    func tooLong(start: Int, length: Int, available: Int) {
        #expect(throws: RangeError.tooLong(available: available)) {
            try CheckedSubarraySum.sum(of: numbers, from: start, length: length)
        }
    }

    @Test("A huge length doesn't crash")
    func hugeLength() {
        #expect(throws: RangeError.tooLong(available: 4)) {
            try CheckedSubarraySum.sum(of: numbers, from: 1, length: Int.max)
        }
    }

    @Test("Checks happen in order")
    func order() {
        // Negative length is reported even when the start is also bad
        #expect(throws: RangeError.negativeLength(-1)) {
            try CheckedSubarraySum.sum(of: numbers, from: -3, length: -1)
        }
        // A bad start is reported before the window length is considered
        #expect(throws: RangeError.startOutOfBounds(9)) {
            try CheckedSubarraySum.sum(of: numbers, from: 9, length: 50)
        }
    }

    @Test("Works on a long array")
    func longArray() throws {
        let big = Array(1...100_000)
        #expect(try CheckedSubarraySum.sum(of: big, from: 0, length: 100_000) == 5_000_050_000)
        #expect(try CheckedSubarraySum.sum(of: big, from: 99_990, length: 10) == 999_955)
    }
}
