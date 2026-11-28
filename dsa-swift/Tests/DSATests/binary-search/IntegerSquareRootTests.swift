import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct IntegerSquareRootTests {
    @Test("Small values", arguments: [
        (0, 0), (1, 1), (2, 1), (3, 1), (4, 2), (8, 2), (9, 3), (10, 3),
        (15, 3), (16, 4), (24, 4), (25, 5), (26, 5), (99, 9), (100, 10),
    ])
    func small(x: Int, expected: Int) {
        #expect(IntegerSquareRoot.floorRoot(of: x) == expected)
    }

    @Test("Every value up to 20,000")
    func exhaustive() {
        var root = 0
        var firstMismatch: Int? = nil
        for x in 0...20_000 {
            while (root + 1) * (root + 1) <= x {
                root += 1
            }
            if IntegerSquareRoot.floorRoot(of: x) != root {
                firstMismatch = firstMismatch ?? x
            }
        }
        #expect(firstMismatch == nil, "the first x where the answer is wrong")
    }

    @Test("Around large perfect squares", arguments: [
        46_340, 46_341, 65_536, 1_000_000, 999_999_999, 1_000_000_000, 2_147_483_647, 3_037_000_499,
    ])
    func aroundSquares(r: Int) {
        let square = r * r
        #expect(IntegerSquareRoot.floorRoot(of: square - 1) == r - 1)
        #expect(IntegerSquareRoot.floorRoot(of: square) == r)
        #expect(IntegerSquareRoot.floorRoot(of: square + 1) == r)
    }

    @Test("Where Double's rounding gives the wrong answer")
    func beyondDouble() {
        // Double(999_999_999_999_999_999) rounds up to 10¹⁸, whose square root is exactly 10⁹
        #expect(IntegerSquareRoot.floorRoot(of: 999_999_999_999_999_999) == 999_999_999)
        #expect(IntegerSquareRoot.floorRoot(of: 1_000_000_000_000_000_000) == 1_000_000_000)
    }

    @Test("Int.max doesn't overflow")
    func intMax() {
        #expect(IntegerSquareRoot.floorRoot(of: Int.max) == 3_037_000_499)
        #expect(IntegerSquareRoot.floorRoot(of: Int.max - 1) == 3_037_000_499)
    }

    @Test("Thousands of large values")
    func large() {
        var wrong = 0
        for step in 0..<5_000 {
            let x = Int.max - step * 1_844_674_407_370_955     // from Int.max down to about 0
            let r = IntegerSquareRoot.floorRoot(of: x)
            // r × r ≤ x < (r + 1) × (r + 1), checked without overflowing
            let fits = r >= 0 && (r == 0 || r <= x / r)
            let next = r + 1
            let nextTooBig = next > x / next
            if !(fits && nextTooBig) {
                wrong += 1
            }
        }
        #expect(wrong == 0)
    }
}
