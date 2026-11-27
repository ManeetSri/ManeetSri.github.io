import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct KaratsubaRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct KaratsubaLongProductTests {
    /// Schoolbook multiplication of decimal strings. Quadratic, but clearly right.
    private func schoolbook(_ a: String, _ b: String) -> String {
        let x = a.utf8.reversed().map { Int($0) - 48 }
        let y = b.utf8.reversed().map { Int($0) - 48 }
        var result = Array(repeating: 0, count: x.count + y.count)
        for i in x.indices {
            for j in y.indices {
                result[i + j] += x[i] * y[j]        // at most 81 per pair, so no cell overflows
            }
        }
        var carry = 0
        for index in result.indices {
            let total = result[index] + carry
            result[index] = total % 10
            carry = total / 10
        }
        while result.count > 1 && result.last == 0 {
            result.removeLast()
        }
        return String(result.reversed().map { Character(String($0)) })
    }

    private func randomNumber(_ digits: Int, _ random: inout KaratsubaRandom) -> String {
        if digits == 1 {
            return String(Int.random(in: 0...9, using: &random))
        }
        var text = String(Int.random(in: 1...9, using: &random))
        for _ in 1..<digits {
            text += String(Int.random(in: 0...9, using: &random))
        }
        return text
    }

    /// The remainder of a decimal string modulo m, digit by digit
    private func remainder(_ text: String, _ m: Int) -> Int {
        text.reduce(0) { ($0 * 10 + ($1.wholeNumberValue ?? 0)) % m }
    }

    @Test("Examples and small cases", arguments: [
        ("12", "34", "408"),
        ("0", "98765", "0"),
        ("999", "999", "998001"),
        ("1", "5", "5"),
        ("123456789", "987654321", "121932631112635269"),
        ("7", "0", "0"),
        ("10", "10", "100"),
        ("25", "4", "100"),
        ("99999999999999999999", "2", "199999999999999999998"),
        ("31415926535897932384626433832795", "27182818284590452353602874713527",
         "853973422267356706546355086954668447174445893592492906242717965"),
    ] as [(String, String, String)])
    func examples(a: String, b: String, expected: String) {
        #expect(KaratsubaLongProduct.multiply(a, b) == expected)
    }

    @Test("Matches schoolbook on 300 random pairs up to 150 digits")
    func randomSmall() {
        var random = KaratsubaRandom(seed: 1_962)
        for _ in 0..<300 {
            let a = randomNumber(Int.random(in: 1...150, using: &random), &random)
            let b = randomNumber(Int.random(in: 1...150, using: &random), &random)
            #expect(KaratsubaLongProduct.multiply(a, b) == schoolbook(a, b))
        }
    }

    @Test("Matches schoolbook on uneven and medium lengths")
    func randomMedium() {
        var random = KaratsubaRandom(seed: 1_960)
        for (first, second) in [(500, 500), (777, 3), (64, 650), (700, 699), (401, 129)] {
            let a = randomNumber(first, &random)
            let b = randomNumber(second, &random)
            #expect(KaratsubaLongProduct.multiply(a, b) == schoolbook(a, b))
            #expect(KaratsubaLongProduct.multiply(b, a) == schoolbook(a, b))
        }
    }

    @Test("10,000 nines squared")
    func ninesSquared() {
        // (10^n - 1)² = 10^(2n) - 2·10^n + 1: n - 1 nines, an 8, n - 1 zeros and a 1
        let n = 10_000
        let nines = String(repeating: "9", count: n)
        let expected = String(repeating: "9", count: n - 1) + "8" + String(repeating: "0", count: n - 1) + "1"
        #expect(KaratsubaLongProduct.multiply(nines, nines) == expected)
    }

    @Test("8,000-digit random numbers, checked by their remainders")
    func largeRandom() {
        var random = KaratsubaRandom(seed: 2_048)
        let a = randomNumber(8_000, &random)
        let b = randomNumber(7_919, &random)
        let product = KaratsubaLongProduct.multiply(a, b)
        // A product has as many digits as both factors together, or one fewer, with no leading zero
        #expect(product.count == a.count + b.count || product.count == a.count + b.count - 1)
        #expect(product.first != "0")
        for m in [1_000_000_007, 998_244_353, 999_999_937, 10_000] {
            #expect(remainder(product, m) == remainder(a, m) * remainder(b, m) % m)
        }
    }

    @Test("Long numbers times 1, 0 and powers of ten")
    func largeSpecial() {
        var random = KaratsubaRandom(seed: 99)
        let a = randomNumber(8_000, &random)
        #expect(KaratsubaLongProduct.multiply(a, "1") == a)
        #expect(KaratsubaLongProduct.multiply("0", a) == "0")
        let power = "1" + String(repeating: "0", count: 5_000)
        #expect(KaratsubaLongProduct.multiply(a, power) == a + String(repeating: "0", count: 5_000))
    }
}
