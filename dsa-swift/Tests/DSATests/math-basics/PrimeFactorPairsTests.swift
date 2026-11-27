import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct PrimeFactorPairsTests {
    /// Tuples aren't Equatable, so compare factorisations as [[prime, exponent]].
    private func pairs(_ n: Int) -> [[Int]] {
        PrimeFactorPairs.factorise(n).map { [$0.prime, $0.exponent] }
    }

    @Test("Factorises the examples", arguments: [
        (360, [[2, 3], [3, 2], [5, 1]]),
        (97, [[97, 1]]),
        (1024, [[2, 10]]),
        (1_000_000_000_000, [[2, 12], [5, 12]]),
        (2, [[2, 1]]),
        (12, [[2, 2], [3, 1]]),
        (84, [[2, 2], [3, 1], [7, 1]]),
        (49, [[7, 2]]),
        (30_030, [[2, 1], [3, 1], [5, 1], [7, 1], [11, 1], [13, 1]]),
    ])
    func factorises(n: Int, expected: [[Int]]) {
        #expect(pairs(n) == expected)
    }

    @Test("1 has no prime factors and one divisor")
    func one() {
        #expect(PrimeFactorPairs.factorise(1).isEmpty)
        #expect(PrimeFactorPairs.divisorCount(of: 1) == 1)
    }

    @Test("Keeps a large leftover prime")
    func leftoverPrime() {
        #expect(pairs(600_851_475_143) == [[71, 1], [839, 1], [1_471, 1], [6_857, 1]])
        #expect(pairs(2 * 499_999_999_979) == [[2, 1], [499_999_999_979, 1]])
        #expect(pairs(999_999_999_989) == [[999_999_999_989, 1]])
    }

    @Test("Square of a large prime")
    func squareOfPrime() {
        #expect(pairs(999_966_000_289) == [[999_983, 2]])
        #expect(PrimeFactorPairs.divisorCount(of: 999_966_000_289) == 3)
    }

    @Test("Counts divisors", arguments: [
        (360, 24),
        (97, 2),
        (1024, 11),
        (1_000_000_000_000, 169),
        (36, 9),
        (28, 6),
        (720_720, 240),
        (999_999_999_989, 2),
    ])
    func divisorCount(n: Int, expected: Int) {
        #expect(PrimeFactorPairs.divisorCount(of: n) == expected)
    }

    @Test("Multiplying the factors back gives n", arguments: [2, 3, 360, 5_040, 65_536, 123_456_789, 987_654_321_000])
    func rebuilds(n: Int) {
        var product = 1
        for factor in PrimeFactorPairs.factorise(n) {
            for _ in 0..<factor.exponent {
                product *= factor.prime
            }
        }
        #expect(product == n)
    }
}
