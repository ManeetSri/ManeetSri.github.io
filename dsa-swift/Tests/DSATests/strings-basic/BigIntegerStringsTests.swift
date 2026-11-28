import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct BigIntegerStringsTests {
    @Test("Adds", arguments: [
        ("12", "30", "42"),
        ("999", "1", "1000"),
        ("0", "0", "0"),
        ("-15", "15", "0"),
        ("-15", "10", "-5"),
        ("15", "-10", "5"),
        ("-7", "-8", "-15"),
        ("1000", "-1", "999"),
        ("-1000", "999", "-1"),
        ("99999999999999999999", "1", "100000000000000000000"),
        ("-100000000000000000000", "1", "-99999999999999999999"),
    ])
    func adds(a: String, b: String, expected: String) {
        #expect(BigIntegerStrings.add(a, b) == expected)
    }

    @Test("Multiplies", arguments: [
        ("12", "34", "408"),
        ("0", "987654321", "0"),
        ("-3", "7", "-21"),
        ("-3", "-7", "21"),
        ("-12345", "0", "0"),
        ("99", "99", "9801"),
        ("123456789", "987654321", "121932631112635269"),
        ("99999999999999999999", "99999999999999999999", "9999999999999999999800000000000000000001"),
    ])
    func multiplies(a: String, b: String, expected: String) {
        #expect(BigIntegerStrings.multiply(a, b) == expected)
    }

    @Test("Agrees with Int arithmetic on many pairs")
    func matchesInt() {
        var firstMismatch: String? = nil
        var state: UInt64 = 2024
        func next() -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int(state >> 33) % 2_000_000_001 - 1_000_000_000
        }
        for round in 0..<500 {
            var a = next()
            var b = next()
            if round % 5 == 0 { a /= 100_000 }
            if round % 7 == 0 { b = round % 2 == 0 ? 0 : -a }
            if BigIntegerStrings.add(String(a), String(b)) != String(a + b)
                || BigIntegerStrings.multiply(String(a), String(b)) != String(a * b) {
                firstMismatch = firstMismatch ?? "\(a) and \(b)"
            }
        }
        #expect(firstMismatch == nil, "the first pair where the answer differs from Int arithmetic")
    }

    @Test("Handles 1,000-digit numbers")
    func large() {
        // (10ⁿ - 1)² = 99...9 8 00...0 1, with n - 1 nines and n - 1 zeros
        let n = 1_000
        let nines = String(repeating: "9", count: n)
        let square = String(repeating: "9", count: n - 1) + "8" + String(repeating: "0", count: n - 1) + "1"
        #expect(BigIntegerStrings.multiply(nines, nines) == square)
        #expect(BigIntegerStrings.multiply("-" + nines, nines) == "-" + square)
        #expect(BigIntegerStrings.add(nines, "1") == "1" + String(repeating: "0", count: n))
        #expect(BigIntegerStrings.add(nines, "-" + nines) == "0")
        #expect(BigIntegerStrings.add("1" + String(repeating: "0", count: n), "-1") == nines)
    }
}
