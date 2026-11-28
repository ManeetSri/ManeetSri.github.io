import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct PrimeSieveTests {
    @Test("Small limits", arguments: [
        (10, [2, 3, 5, 7]),
        (30, [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]),
        (2, [2]),
        (3, [2, 3]),
        (4, [2, 3]),
        (25, [2, 3, 5, 7, 11, 13, 17, 19, 23]),
        (49, [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]),
    ])
    func small(n: Int, expected: [Int]) {
        #expect(PrimeSieve.primes(upTo: n) == expected)
    }

    @Test("No primes below 2", arguments: [0, 1])
    func none(n: Int) {
        #expect(PrimeSieve.primes(upTo: n).isEmpty)
    }

    @Test("Includes n when n is prime and squares are excluded")
    func boundaries() {
        #expect(PrimeSieve.primes(upTo: 97).last == 97)
        #expect(PrimeSieve.primes(upTo: 121).last == 113)
        #expect(!PrimeSieve.primes(upTo: 1_000).contains(961))
    }

    @Test("Known counts", arguments: [
        (100, 25),
        (1_000, 168),
        (10_000, 1_229),
        (1_000_000, 78_498),
    ])
    func counts(n: Int, expected: Int) {
        #expect(PrimeSieve.primes(upTo: n).count == expected)
    }

    @Test("The largest allowed limit")
    func largest() {
        let primes = PrimeSieve.primes(upTo: 5_000_000)
        #expect(primes.count == 348_513)
        #expect(primes.last == 4_999_999)
    }

    @Test("Matches trial division up to 2,000")
    func matchesTrialDivision() {
        let expected = (2...2_000).filter { candidate in
            var d = 2
            while d * d <= candidate {
                if candidate % d == 0 { return false }
                d += 1
            }
            return true
        }
        #expect(PrimeSieve.primes(upTo: 2_000) == expected)
    }
}
