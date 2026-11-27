import Foundation
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct NthRootBisectionTests {
    /// baseⁿ, or nil if it doesn't fit in an Int.
    private func power(_ base: Int, _ n: Int) -> Int? {
        var result = 1
        for _ in 0..<n {
            let (product, overflow) = result.multipliedReportingOverflow(by: base)
            if overflow { return nil }
            result = product
        }
        return result
    }

    /// True if r is the floor of the nth root of x: rⁿ ≤ x < (r + 1)ⁿ.
    private func isFloorRoot(_ r: Int, of x: Int, degree n: Int) -> Bool {
        guard r >= 0, let low = power(r, n), low <= x else { return false }
        guard r < Int.max, let high = power(r + 1, n) else { return true }   // (r + 1)ⁿ overflows, so it's > x
        return high > x
    }

    @Test("Whole roots in the examples", arguments: [
        (30, 2, 5),
        (1_000, 3, 10),
        (999, 3, 9),
        (0, 5, 0),
        (1, 7, 1),
        (7, 1, 7),
        (Int.max, 2, 3_037_000_499),
        (Int.max, 63, 1),
    ])
    func wholeExamples(x: Int, n: Int, expected: Int) {
        #expect(NthRootBisection.floorRoot(of: x, degree: n) == expected)
    }

    @Test("Whole roots match a slow count for every x up to 2,000")
    func wholeSmall() {
        var firstMismatch: String? = nil
        for n in 1...12 {
            var r = 0
            for x in 0...2_000 {
                while power(r + 1, n)! <= x { r += 1 }
                if NthRootBisection.floorRoot(of: x, degree: n) != r {
                    firstMismatch = firstMismatch ?? "x = \(x), n = \(n)"
                }
            }
        }
        #expect(firstMismatch == nil, "the first input where the root is wrong")
    }

    @Test("Perfect powers and their neighbours, right up to Int.max")
    func perfectPowers() {
        var firstMismatch: String? = nil
        for n in 2...64 {
            for x in [Int.max, Int.max - 1, 1 << 62, (1 << 62) - 1] where !isFloorRoot(NthRootBisection.floorRoot(of: x, degree: n), of: x, degree: n) {
                firstMismatch = firstMismatch ?? "x = \(x), n = \(n)"
            }
            for r in [2, 3, 10, 999, 55_108, 3_037_000_499] {
                guard let exact = power(r, n) else { continue }
                for x in [exact - 1, exact, exact + 1] where x >= 0 && !isFloorRoot(NthRootBisection.floorRoot(of: x, degree: n), of: x, degree: n) {
                    firstMismatch = firstMismatch ?? "x = \(x), n = \(n)"
                }
            }
        }
        #expect(firstMismatch == nil, "the first input where the root is wrong")
        #expect(NthRootBisection.floorRoot(of: Int.max, degree: 3) == 2_097_151)
        #expect(NthRootBisection.floorRoot(of: 1 << 62, degree: 62) == 2)
        #expect(NthRootBisection.floorRoot(of: 64, degree: 3) == 4)
        #expect(NthRootBisection.floorRoot(of: 343, degree: 3) == 7)
    }

    @Test("Decimal roots in the examples", arguments: [
        (2.0, 2, 1.4142135623730951),
        (0.25, 2, 0.5),
        (1e18, 3, 1_000_000.0),
        (27.0, 3, 3.0),
        (5.5, 1, 5.5),
        (1.0, 30, 1.0),
    ])
    func decimalExamples(x: Double, n: Int, expected: Double) {
        let root = NthRootBisection.root(of: x, degree: n)
        #expect(abs(root - expected) <= 1e-9 * max(1, expected), "got \(root)")
    }

    @Test("Decimal roots match pow across a wide range")
    func decimalRange() {
        var firstMismatch: String? = nil
        let values: [Double] = [0, 1e-12, 0.001, 0.3, 0.999, 1.5, 2, 10, 123.456, 1e6, 7.77e11, 1e18]
        for x in values {
            for n in 1...30 {
                let expected = pow(x, 1.0 / Double(n))
                let root = NthRootBisection.root(of: x, degree: n)
                if !(abs(root - expected) <= 1e-9 * max(1, expected)) {
                    firstMismatch = firstMismatch ?? "x = \(x), n = \(n): got \(root), expected \(expected)"
                }
            }
        }
        #expect(firstMismatch == nil, "the first input where the root is too far off")
    }
}
