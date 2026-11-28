import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct MultipleRoundingTests {
    @Test("Rounds down", arguments: [
        (17, 5, 15), (15, 5, 15), (19, 5, 15), (4, 5, 0), (99, 10, 90),
        (-7, 5, -10), (-10, 5, -10), (-1, 5, -5), (-11, 10, -20),
    ])
    func down(value: Int, step: Int, expected: Int) {
        #expect(MultipleRounding.rounded(value, downToMultipleOf: step) == expected)
    }

    @Test("Rounds up", arguments: [
        (17, 5, 20), (15, 5, 15), (11, 5, 15), (1, 5, 5), (30, 6, 30),
        (-7, 5, -5), (-10, 5, -10), (-4, 5, 0), (-21, 10, -20),
    ])
    func up(value: Int, step: Int, expected: Int) {
        #expect(MultipleRounding.rounded(value, upToMultipleOf: step) == expected)
    }

    @Test("Rounds to the nearest", arguments: [
        (17, 5, 15), (18, 5, 20), (20, 5, 20), (2, 5, 0), (3, 5, 5),
        (-7, 5, -5), (-8, 5, -10), (-2, 5, 0), (-3, 5, -5), (1_234, 100, 1_200),
    ])
    func nearest(value: Int, step: Int, expected: Int) {
        #expect(MultipleRounding.rounded(value, toNearestMultipleOf: step) == expected)
    }

    @Test("A tie goes to the larger multiple", arguments: [
        (15, 10, 20), (-15, 10, -10), (5, 10, 10), (-5, 10, 0), (1, 2, 2), (-1, 2, 0),
    ])
    func ties(value: Int, step: Int, expected: Int) {
        #expect(MultipleRounding.rounded(value, toNearestMultipleOf: step) == expected)
    }

    @Test("Zero is a multiple of every step", arguments: [1, 2, 7, 1_000_000_000])
    func zero(step: Int) {
        #expect(MultipleRounding.rounded(0, downToMultipleOf: step) == 0)
        #expect(MultipleRounding.rounded(0, upToMultipleOf: step) == 0)
        #expect(MultipleRounding.rounded(0, toNearestMultipleOf: step) == 0)
    }

    @Test("A step of 1 leaves every value unchanged", arguments: [-1_000_000_000, -3, 8, 1_000_000_000])
    func stepOne(value: Int) {
        #expect(MultipleRounding.rounded(value, downToMultipleOf: 1) == value)
        #expect(MultipleRounding.rounded(value, upToMultipleOf: 1) == value)
        #expect(MultipleRounding.rounded(value, toNearestMultipleOf: 1) == value)
    }

    @Test("Handles the largest values and steps")
    func extremes() {
        let big = 1_000_000_000
        #expect(MultipleRounding.rounded(big - 1, downToMultipleOf: big) == 0)
        #expect(MultipleRounding.rounded(big - 1, upToMultipleOf: big) == big)
        #expect(MultipleRounding.rounded(big - 1, toNearestMultipleOf: big) == big)
        #expect(MultipleRounding.rounded(-big + 1, downToMultipleOf: big) == -big)
        #expect(MultipleRounding.rounded(-big + 1, upToMultipleOf: big) == 0)
        #expect(MultipleRounding.rounded(-big, upToMultipleOf: 3) == -999_999_999)
    }
}
