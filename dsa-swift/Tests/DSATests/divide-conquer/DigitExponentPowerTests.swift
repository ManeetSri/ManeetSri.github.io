import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct ExponentRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct DigitExponentPowerTests {
    /// Ordinary fast power for an exponent that fits in an Int
    private func modPow(_ base: Int, _ exponent: Int, _ m: Int) -> Int {
        var result = 1 % m
        var square = ((base % m) + m) % m
        var e = exponent
        while e > 0 {
            if e % 2 == 1 {
                result = result * square % m
            }
            square = square * square % m
            e /= 2
        }
        return result
    }

    /// A different route for long exponents: read the digits from the least significant end, keeping
    /// base^(10^i) and multiplying in base^(digit · 10^i)
    private func rightToLeft(_ base: Int, _ digits: [Int], _ m: Int) -> Int {
        var result = 1 % m
        var place = ((base % m) + m) % m             // base^(10^i)
        for digit in digits.reversed() {
            result = result * modPow(place, digit, m) % m
            place = modPow(place, 10, m)
        }
        return result
    }

    private func digits(of number: Int) -> [Int] {
        String(number).map { $0.wholeNumberValue! }
    }

    private func randomDigits(_ count: Int, _ random: inout ExponentRandom) -> [Int] {
        [Int.random(in: 1...9, using: &random)] + (1..<max(count, 1)).map { _ in Int.random(in: 0...9, using: &random) }
    }

    @Test("Examples and small cases", arguments: [
        (3, [1, 3], 1_000, 323),
        (2, [1, 0], 1_000, 24),
        (-2, [3], 5, 2),
        (7, [0], 13, 1),
        (0, [0], 7, 1),
        (5, [2, 0], 1, 0),
        (10, [1, 0, 0], 7, 4),
        (0, [5], 9, 0),
        (-1, [1, 0, 0, 1], 1_000, 999),
        (12, [2], 144, 0),
        (1_000_000_000_000_000_000, [2], 1_000_000_007, 2_401),
        (-1_000_000_000_000_000_000, [3], 1_000_000_007, 999_882_358),
    ] as [(Int, [Int], Int, Int)])
    func examples(base: Int, exponentDigits: [Int], modulus: Int, expected: Int) {
        #expect(DigitExponentPower.remainder(base: base, exponentDigits: exponentDigits, modulus: modulus) == expected)
    }

    @Test("Matches ordinary fast power on 500 exponents that fit in an Int")
    func randomFits() {
        var random = ExponentRandom(seed: 372)
        for _ in 0..<500 {
            let base = Int.random(in: -1_000_000_000_000_000_000...1_000_000_000_000_000_000, using: &random)
            let exponent = Int.random(in: 0...Int.random(in: 1...1_000_000_000_000_000_000, using: &random), using: &random)
            let modulus = Int.random(in: 1...2_000_000_000, using: &random)
            #expect(DigitExponentPower.remainder(base: base, exponentDigits: digits(of: exponent), modulus: modulus)
                    == modPow(base, exponent, modulus))
        }
    }

    @Test("Long exponents with prime moduli, checked by reducing the exponent modulo p - 1")
    func primeModuli() {
        // For a prime p and a base it doesn't divide, base^(p - 1) leaves remainder 1, so only the
        // exponent's remainder modulo p - 1 matters
        var random = ExponentRandom(seed: 1_640)
        for p in [1_000_000_007, 998_244_353, 1_999_999_973, 13, 2] {
            for _ in 0..<5 {
                var base = Int.random(in: 1...1_000_000_000_000, using: &random)
                if base % p == 0 { base += 1 }
                let exponent = randomDigits(Int.random(in: 1_000...10_000, using: &random), &random)
                let reduced = exponent.reduce(0) { ($0 * 10 + $1) % (p - 1 == 0 ? 1 : p - 1) }
                #expect(DigitExponentPower.remainder(base: base, exponentDigits: exponent, modulus: p)
                        == modPow(base, reduced, p))
            }
        }
    }

    @Test("Long exponents with any modulus match a right-to-left calculation")
    func compositeModuli() {
        var random = ExponentRandom(seed: 2_718)
        for _ in 0..<40 {
            let base = Int.random(in: -1_000_000_000_000_000_000...1_000_000_000_000_000_000, using: &random)
            let exponent = randomDigits(Int.random(in: 20...10_000, using: &random), &random)
            let modulus = Int.random(in: 1...2_000_000_000, using: &random)
            #expect(DigitExponentPower.remainder(base: base, exponentDigits: exponent, modulus: modulus)
                    == rightToLeft(base, exponent, modulus))
        }
    }

    @Test("Special long exponents")
    func special() {
        // 10^9999 is even, so (-1) to that power is 1; 1 to any power is 1; 0 to a positive power is 0
        let tenToTheBig = [1] + Array(repeating: 0, count: 9_999)
        #expect(DigitExponentPower.remainder(base: -1, exponentDigits: tenToTheBig, modulus: 1_000) == 1)
        #expect(DigitExponentPower.remainder(base: 1, exponentDigits: tenToTheBig, modulus: 97) == 1)
        #expect(DigitExponentPower.remainder(base: 0, exponentDigits: tenToTheBig, modulus: 97) == 0)
        // 2^(10^9999) modulo 1,024 is 0, because the exponent is at least 10
        #expect(DigitExponentPower.remainder(base: 2, exponentDigits: tenToTheBig, modulus: 1_024) == 0)
        // Modulo 1, every remainder is 0
        #expect(DigitExponentPower.remainder(base: 5, exponentDigits: tenToTheBig, modulus: 1) == 0)
    }
}
