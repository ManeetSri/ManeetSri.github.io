import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct CheckedDivisionTests {
    typealias DivisionError = CheckedDivision.DivisionError

    @Test("Divides like Swift's / operator", arguments: [
        (7, 2, 3),
        (-7, 2, -3),
        (7, -2, -3),
        (-7, -2, 3),
        (0, 5, 0),
        (12, 4, 3),
        (1, 1, 1),
    ])
    func divides(dividend: Int, divisor: Int, expected: Int) {
        #expect(CheckedDivision.divide(dividend, by: divisor) == .success(expected))
    }

    @Test("Dividing by zero fails", arguments: [0, 1, -1, Int.max, Int.min])
    func byZero(dividend: Int) {
        #expect(CheckedDivision.divide(dividend, by: 0) == .failure(DivisionError.divisionByZero))
    }

    @Test("Int.min / -1 overflows")
    func overflow() {
        #expect(CheckedDivision.divide(Int.min, by: -1) == .failure(DivisionError.overflow))
    }

    @Test("The extremes that do fit")
    func extremes() {
        #expect(CheckedDivision.divide(Int.min, by: 1) == .success(Int.min))
        #expect(CheckedDivision.divide(Int.max, by: -1) == .success(-Int.max))
        #expect(CheckedDivision.divide(Int.min, by: 2) == .success(Int.min / 2))
    }

    @Test("Chains divisions left to right")
    func chains() {
        #expect(CheckedDivision.divide(100, byEach: [2, 5]) == .success(10))
        #expect(CheckedDivision.divide(1_000, byEach: [10, 3, 2]) == .success(16))
        #expect(CheckedDivision.divide(-90, byEach: [-3, 4]) == .success(7))
    }

    @Test("No divisors leaves the start unchanged")
    func noDivisors() {
        #expect(CheckedDivision.divide(42, byEach: []) == .success(42))
    }

    @Test("A chain stops at its first failure")
    func chainFailure() {
        #expect(CheckedDivision.divide(100, byEach: [2, 0, 5]) == .failure(DivisionError.divisionByZero))
        #expect(CheckedDivision.divide(Int.min, byEach: [1, -1, 0]) == .failure(DivisionError.overflow))
    }

    @Test("The result works with get()")
    func worksWithGet() throws {
        let value = try CheckedDivision.divide(81, byEach: [3, 3]).get()
        #expect(value == 9)
        #expect(throws: DivisionError.divisionByZero) {
            try CheckedDivision.divide(1, by: 0).get()
        }
    }
}
