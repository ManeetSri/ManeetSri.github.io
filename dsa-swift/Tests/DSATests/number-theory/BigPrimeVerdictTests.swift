import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct BigPrimeVerdictTests {
    @Test("Small cases and famous liars", arguments: [
        (0, false), (1, false), (2, true), (3, true), (4, false), (5, true), (9, false), (37, true), (41, true),
        (561, false),                         // Carmichael: fools Fermat's test for every coprime base
        (2_047, false),                       // the smallest number that fools Miller–Rabin with base 2
        (1_373_653, false),                   // fools bases 2 and 3
        (25_326_001, false),                  // fools bases 2, 3 and 5
        (3_215_031_751, false),               // fools bases 2, 3, 5 and 7
        (2_152_302_898_747, false),           // fools bases 2 to 11
        (3_474_749_660_383, false),           // fools bases 2 to 13
        (341_550_071_728_321, false),         // fools bases 2 to 17
        (3_825_123_056_546_413_051, false),   // fools every base from 2 to 31
        (1_000_000_007, true),
        (998_244_353, true),
    ] as [(UInt64, Bool)])
    func examples(n: UInt64, expected: Bool) {
        #expect(BigPrimeVerdict.isPrime(n) == expected)
    }

    @Test("Big primes near the top of the range", arguments: [
        18_446_744_073_709_551_557,          // the largest prime below 2⁶⁴
        18_446_744_073_709_551_533,
        9_223_372_036_854_775_783,           // the largest prime below 2⁶³
        4_611_686_018_427_387_847,
        2_305_843_009_213_693_951,           // 2⁶¹ − 1
        1_000_000_000_000_000_003,
        1_000_000_000_000_000_009,
        999_999_999_989,
        4_294_967_291,
    ] as [UInt64])
    func bigPrimes(n: UInt64) {
        #expect(BigPrimeVerdict.isPrime(n))
    }

    @Test("Big composites built from big primes")
    func bigComposites() {
        let nearTwo32: [UInt64] = [4_294_967_291, 4_294_967_279, 4_294_967_231, 4_294_967_197]
        for p in nearTwo32 {
            for q in nearTwo32 {
                #expect(!BigPrimeVerdict.isPrime(p * q), "\(p) × \(q)")    // includes the squares
            }
        }
        #expect(!BigPrimeVerdict.isPrime(UInt64.max))                     // 3 · 5 · 17 · 257 · 641 · 65537 · 6700417
        #expect(!BigPrimeVerdict.isPrime(UInt64.max - 1))
        #expect(!BigPrimeVerdict.isPrime(1_000_000_007 * 1_000_000_009))
        #expect(!BigPrimeVerdict.isPrime(999_999_999_989 * 18_446_743))
        #expect(!BigPrimeVerdict.isPrime(9_746_347_772_161))              // a Carmichael number
        #expect(!BigPrimeVerdict.isPrime(18_446_744_073_709_551_557 - 2))
    }

    @Test("Agrees with a sieve for every number below 100,000")
    func sieve() {
        let limit = 100_000
        var isPrime = Array(repeating: true, count: limit)
        isPrime[0] = false
        isPrime[1] = false
        var p = 2
        while p * p < limit {
            if isPrime[p] {
                for m in stride(from: p * p, to: limit, by: p) { isPrime[m] = false }
            }
            p += 1
        }
        var mismatches: [Int] = []
        for n in 0..<limit where BigPrimeVerdict.isPrime(UInt64(n)) != isPrime[n] {
            mismatches.append(n)
        }
        #expect(mismatches.isEmpty, "first mismatches: \(mismatches.prefix(5))")
    }

    @Test("Counts the primes in a window just below 2⁶⁴")
    func topWindow() {
        // The primes among the last 1,000 numbers below 2⁶⁴, found by subtracting from UInt64.max
        let primes = (UInt64(0)..<1_000).map { UInt64.max - $0 }.filter { BigPrimeVerdict.isPrime($0) }
        #expect(primes.first == 18_446_744_073_709_551_557)
        #expect(primes.count == 21)
    }
}
