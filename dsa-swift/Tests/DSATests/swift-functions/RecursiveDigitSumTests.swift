import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct RecursiveDigitSumTests {
    @Test("Adds up the digits", arguments: [
        (0, 0),
        (7, 7),
        (10, 1),
        (123, 6),
        (1_000, 1),
        (9_999, 36),
        (40_506, 15),
    ])
    func digitSum(n: Int, expected: Int) {
        #expect(RecursiveDigitSum.digitSum(n) == expected)
    }

    @Test("Handles the largest Int")
    func largestDigitSum() {
        #expect(RecursiveDigitSum.digitSum(Int.max) == 88)
    }

    @Test("Reduces to a single digit", arguments: [
        (0, 0),
        (5, 5),
        (38, 2),
        (99, 9),
        (123, 6),
        (987_654_321, 9),
        (1_000_000_007, 8),
    ])
    func digitalRoot(n: Int, expected: Int) {
        #expect(RecursiveDigitSum.digitalRoot(n) == expected)
    }

    @Test("Digital root of the largest Int")
    func largestDigitalRoot() {
        #expect(RecursiveDigitSum.digitalRoot(Int.max) == 7)
    }
}
