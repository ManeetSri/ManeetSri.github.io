import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct OverflowCheckTests {
    @Test("Additions that fit", arguments: [
        (2, 3),
        (-5, 5),
        (Int.max, 0),
        (Int.max, Int.min),
        (Int.min, 0),
        (Int.max - 1, 1),
        (Int.min + 1, -1),
    ])
    func additionFits(a: Int, b: Int) {
        #expect(!OverflowCheck.additionOverflows(a, b))
    }

    @Test("Additions that overflow", arguments: [
        (Int.max, 1),
        (1, Int.max),
        (Int.min, -1),
        (Int.max, Int.max),
        (Int.min, Int.min),
        (Int.max / 2 + 1, Int.max / 2 + 1),
    ])
    func additionOverflows(a: Int, b: Int) {
        #expect(OverflowCheck.additionOverflows(a, b))
    }

    @Test("Multiplications that fit", arguments: [
        (1_000_000_000, 1_000_000_000),
        (3_037_000_499, 3_037_000_499),
        (Int.max, 1),
        (Int.min, 1),
        (Int.max, -1),
        (0, Int.min),
        (-7, 6),
    ])
    func multiplicationFits(a: Int, b: Int) {
        #expect(!OverflowCheck.multiplicationOverflows(a, b))
    }

    @Test("Multiplications that overflow", arguments: [
        (3_037_000_500, 3_037_000_500),
        (Int.max, 2),
        (Int.min, -1),
        (-1, Int.min),
        (Int.min, 2),
        (-3_037_000_500, 3_037_000_500),
    ])
    func multiplicationOverflows(a: Int, b: Int) {
        #expect(OverflowCheck.multiplicationOverflows(a, b))
    }
}
