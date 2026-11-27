import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ConstraintSpeedTargetTests {
    @Test("Picks the right row for typical sizes", arguments: [
        (8, "O(n!)"),
        (15, "O(2^n)"),
        (300, "O(n^3)"),
        (2_000, "O(n^2)"),
        (100_000, "O(n log n)"),
        (1_000_000_000, "O(log n)"),
    ])
    func typical(maxN: Int, expected: String) {
        #expect(ConstraintSpeedTarget.aim(forMaxN: maxN) == expected)
    }

    @Test("At most includes the limit itself", arguments: [
        (10, "O(n!)"),
        (20, "O(2^n)"),
        (500, "O(n^3)"),
        (5_000, "O(n^2)"),
        (1_000_000, "O(n log n)"),
    ])
    func limitsAreIncluded(maxN: Int, expected: String) {
        #expect(ConstraintSpeedTarget.aim(forMaxN: maxN) == expected)
    }

    @Test("One past each limit moves down a row", arguments: [
        (11, "O(2^n)"),
        (21, "O(n^3)"),
        (501, "O(n^2)"),
        (5_001, "O(n log n)"),
        (1_000_001, "O(log n)"),
    ])
    func onePastEachLimit(maxN: Int, expected: String) {
        #expect(ConstraintSpeedTarget.aim(forMaxN: maxN) == expected)
    }

    @Test("Closes the gap between a million and a billion")
    func gap() {
        #expect(ConstraintSpeedTarget.aim(forMaxN: 5_000_000) == "O(log n)")
        #expect(ConstraintSpeedTarget.aim(forMaxN: 999_999_999) == "O(log n)")
    }

    @Test("Handles the smallest and largest sizes")
    func extremes() {
        #expect(ConstraintSpeedTarget.aim(forMaxN: 1) == "O(n!)")
        #expect(ConstraintSpeedTarget.aim(forMaxN: 1_000_000_000_000_000_000) == "O(log n)")
    }
}
