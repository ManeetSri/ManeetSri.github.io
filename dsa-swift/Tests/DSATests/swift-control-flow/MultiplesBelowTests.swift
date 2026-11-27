import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct MultiplesBelowTests {
    @Test("Sums the multiples of either divisor", arguments: [
        (10, 3, 5, 23),
        (20, 4, 6, 64),
        (16, 3, 5, 60),
        (30, 7, 11, 103),
    ])
    func sums(limit: Int, a: Int, b: Int, expected: Int) {
        #expect(MultiplesBelow.sum(below: limit, divisibleBy: a, or: b) == expected)
    }

    @Test("The limit itself is not included")
    func excludesLimit() {
        #expect(MultiplesBelow.sum(below: 15, divisibleBy: 3, or: 5) == 45)
    }

    @Test("Numbers divisible by both count once")
    func countsOnce() {
        #expect(MultiplesBelow.sum(below: 16, divisibleBy: 3, or: 5) == 60)
        #expect(MultiplesBelow.sum(below: 13, divisibleBy: 2, or: 4) == 42)
    }

    @Test("The same divisor twice")
    func sameDivisor() {
        #expect(MultiplesBelow.sum(below: 10, divisibleBy: 2, or: 2) == 20)
    }

    @Test("A divisor of 1 counts every number")
    func divisorOne() {
        #expect(MultiplesBelow.sum(below: 101, divisibleBy: 1, or: 50) == 5_050)
    }

    @Test("Small limits give 0", arguments: [0, 1, 2])
    func smallLimits(limit: Int) {
        #expect(MultiplesBelow.sum(below: limit, divisibleBy: 3, or: 5) == 0)
    }

    @Test("Divisors bigger than the limit give 0")
    func bigDivisors() {
        #expect(MultiplesBelow.sum(below: 10, divisibleBy: 20, or: 30) == 0)
    }

    @Test("Handles a limit of one million")
    func large() {
        #expect(MultiplesBelow.sum(below: 1_000_000, divisibleBy: 3, or: 5) == 233_333_166_668)
    }
}
