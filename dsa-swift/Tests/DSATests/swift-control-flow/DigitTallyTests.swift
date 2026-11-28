import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct DigitTallyTests {
    @Test("Counts digits of positive numbers", arguments: [
        (7, 1), (10, 2), (99, 2), (100, 3), (4_721, 4), (305, 3), (1_000_000, 7),
    ])
    func positive(number: Int, expected: Int) {
        #expect(DigitTally.count(of: number) == expected)
    }

    @Test("Zero has one digit")
    func zero() {
        #expect(DigitTally.count(of: 0) == 1)
    }

    @Test("The minus sign is not a digit", arguments: [(-5, 1), (-305, 3), (-10, 2), (-99_999, 5)])
    func negative(number: Int, expected: Int) {
        #expect(DigitTally.count(of: number) == expected)
    }

    @Test("Handles the extremes of the allowed range")
    func extremes() {
        #expect(DigitTally.count(of: 1_000_000_000_000_000_000) == 19)
        #expect(DigitTally.count(of: -1_000_000_000_000_000_000) == 19)
        #expect(DigitTally.count(of: 999_999_999_999_999_999) == 18)
    }
}
