import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct DigitRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct DigitStringProductTests {
    /// Long multiplication on digit strings, the way you'd do it on paper: O(a · b)
    private func schoolbook(_ a: String, _ b: String) -> String {
        let x = a.utf8.reversed().map { Int($0) - 48 }
        let y = b.utf8.reversed().map { Int($0) - 48 }
        var digits = Array(repeating: 0, count: x.count + y.count)
        for i in x.indices {
            var carry = 0
            for j in y.indices {
                let value = digits[i + j] + x[i] * y[j] + carry
                digits[i + j] = value % 10
                carry = value / 10
            }
            digits[i + y.count] += carry
        }
        while digits.count > 1 && digits.last == 0 { digits.removeLast() }
        return String(digits.reversed().map { Character(String($0)) })
    }

    private func randomNumber(_ length: Int, _ random: inout DigitRandom) -> String {
        if length == 1 { return String(Int.random(in: 0...9, using: &random)) }
        let first = String(Int.random(in: 1...9, using: &random))
        return first + String((1..<length).map { _ in Character(String(Int.random(in: 0...9, using: &random))) })
    }

    /// The value of a digit string modulo m, by Horner's rule
    private func residue(_ text: String, _ m: Int) -> Int {
        text.utf8.reduce(0) { ($0 * 10 + Int($1) - 48) % m }
    }

    @Test("Examples", arguments: [
        ("123", "45", "5535"),
        ("0", "98765", "0"),
        ("98765", "0", "0"),
        ("9", "9", "81"),
        ("1", "1", "1"),
        ("99", "99", "9801"),
        ("123456789", "987654321", "121932631112635269"),
        ("1000", "1000", "1000000"),
        ("4294967296", "4294967296", "18446744073709551616"),
        ("18446744073709551615", "18446744073709551615", "340282366920938463426481119284349108225"),
    ])
    func examples(a: String, b: String, expected: String) {
        #expect(DigitStringProduct.multiply(a, b) == expected)
    }

    @Test("Matches long multiplication on 300 random pairs")
    func randomSmall() {
        var random = DigitRandom(seed: 998_244_353)
        for _ in 0..<300 {
            let a = randomNumber(Int.random(in: 1...80, using: &random), &random)
            let b = randomNumber(Int.random(in: 1...80, using: &random), &random)
            #expect(DigitStringProduct.multiply(a, b) == schoolbook(a, b), "\(a) × \(b)")
        }
    }

    @Test("(10ⁿ − 1)² for n = 60,000: 99…9800…01")
    func allNines() {
        let n = 60_000
        let nines = String(repeating: "9", count: n)
        let expected = String(repeating: "9", count: n - 1) + "8" + String(repeating: "0", count: n - 1) + "1"
        #expect(DigitStringProduct.multiply(nines, nines) == expected)
    }

    @Test("Two random 100,000-digit numbers")
    func hugeRandom() {
        var random = DigitRandom(seed: 66)
        let a = randomNumber(100_000, &random)
        let b = randomNumber(100_000, &random)
        let product = DigitStringProduct.multiply(a, b)
        // Long multiplication would need 10¹⁰ steps, so check the product through its remainders
        #expect(product.count == 199_999 || product.count == 200_000)
        for m in [1_000_000_007, 998_244_353, 1_000_000_000, 999_999_937] {
            #expect(residue(product, m) == residue(a, m) * residue(b, m) % m, "modulo \(m)")
        }
        #expect(product.first != "0")
    }

    @Test("Uneven lengths, powers of ten and a single digit")
    func uneven() {
        var random = DigitRandom(seed: 7)
        let a = randomNumber(10_000, &random)
        #expect(DigitStringProduct.multiply(a, "1") == a)
        #expect(DigitStringProduct.multiply("1", a) == a)
        #expect(DigitStringProduct.multiply(a, "10") == a + "0")
        #expect(DigitStringProduct.multiply("1" + String(repeating: "0", count: 9_999), a) == a + String(repeating: "0", count: 9_999))
        #expect(DigitStringProduct.multiply(a, "0") == "0")
        let seven = DigitStringProduct.multiply(a, "7")
        #expect(residue(seven, 1_000_000_007) == residue(a, 1_000_000_007) * 7 % 1_000_000_007)
        let b = randomNumber(37, &random)
        let short = String(a.prefix(500))
        #expect(DigitStringProduct.multiply(short, b) == schoolbook(short, b))
    }
}
