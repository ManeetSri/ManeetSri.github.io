import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ModularPowerTests {
    @Test("The examples", arguments: [
        (2, 10, 1000, 24),
        (3, 200, 1000, 1),
        (-2, 3, 5, 2),
        (5, 0, 7, 1),
        (7, 123, 1, 0),
        (2, 1_000_000_000_000_000_000, 1_000_000_007, 719_476_260),
    ])
    func examples(base: Int, exponent: Int, m: Int, expected: Int) {
        #expect(ModularPower.power(base, exponent, modulo: m) == expected)
    }

    @Test("Powers of zero and one")
    func zeroAndOne() {
        #expect(ModularPower.power(0, 0, modulo: 7) == 1)
        #expect(ModularPower.power(0, 5, modulo: 7) == 0)
        #expect(ModularPower.power(1, 1_000_000_000_000_000_000, modulo: 13) == 1)
        #expect(ModularPower.power(0, 0, modulo: 1) == 0)
    }

    @Test("Negative bases give a remainder from 0 to m - 1", arguments: [
        (-3, 3, 7, 1),
        (-1, 5, 10, 9),
        (-1, 6, 10, 1),
        (-10, 1, 3, 2),
        (-3, 1_000_000_000_000_000_001, 1_000_000_007, 260_989_958),
        (-1_000_000_000_000_000_000, 7, 1_999_999_973, 435_139_842),
    ])
    func negativeBase(base: Int, exponent: Int, m: Int, expected: Int) {
        #expect(ModularPower.power(base, exponent, modulo: m) == expected)
    }

    @Test("Large bases, exponents and moduli without overflow")
    func large() {
        #expect(ModularPower.power(1_000_000_000_000_000_000, 1_000_000_000_000_000_000, modulo: 1_999_999_973) == 1_999_354_079)
        #expect(ModularPower.power(2, 1_000_000_000_000_000_000, modulo: 2_000_000_000) == 1_787_109_376)
        #expect(ModularPower.power(1_999_999_999, 2, modulo: 2_000_000_000) == 1)
    }

    @Test("Fermat's little theorem: a^(p-1) mod p is 1 for a prime p", arguments: [2, 3, 10, 123_456_789, 999_999_999])
    func fermat(a: Int) {
        #expect(ModularPower.power(a, 1_000_000_006, modulo: 1_000_000_007) == 1)
    }

    @Test("Matches a plain loop for small cases")
    func matchesLoop() {
        var mismatches: [String] = []
        for base in -6...6 {
            for exponent in 0...12 {
                for m in [1, 2, 7, 10, 97] {
                    var expected = 1 % m
                    let reduced = ((base % m) + m) % m
                    for _ in 0..<exponent {
                        expected = expected * reduced % m
                    }
                    if ModularPower.power(base, exponent, modulo: m) != expected {
                        mismatches.append("power(\(base), \(exponent), modulo: \(m)) should be \(expected)")
                    }
                }
            }
        }
        #expect(mismatches.isEmpty, "\(mismatches.count) wrong answers, starting with \(mismatches.prefix(3))")
    }
}
