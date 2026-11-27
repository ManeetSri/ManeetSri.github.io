import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct DigitMessageRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct DigitMessageDecoderTests {
    private let modulus = 1_000_000_007

    /// Try every way to cut the digits into letters. Exponential, but clearly right.
    private func everyReading(_ message: String) -> Int {
        let digits = message.compactMap { $0.wholeNumberValue }
        func read(from i: Int) -> Int {
            if i == digits.count {
                return 1
            }
            var total = 0
            if digits[i] != 0 {
                total += read(from: i + 1)
            }
            if i + 1 < digits.count, (10...26).contains(digits[i] * 10 + digits[i + 1]) {
                total += read(from: i + 2)
            }
            return total
        }
        return read(from: 0)
    }

    /// The same count, filled from the end: ways[i] = decodings of the digits from i onwards
    private func fromTheEnd(_ message: String) -> Int {
        let digits = message.compactMap { $0.wholeNumberValue }
        let n = digits.count
        var ways = Array(repeating: 0, count: n + 2)
        ways[n] = 1
        for i in stride(from: n - 1, through: 0, by: -1) where digits[i] != 0 {
            ways[i] = ways[i + 1]
            if i + 1 < n, digits[i] * 10 + digits[i + 1] <= 26 {
                ways[i] = (ways[i] + ways[i + 2]) % modulus
            }
        }
        return ways[0]
    }

    @Test("Examples and small cases", arguments: [
        ("2611", 4),
        ("1201", 1),
        ("06", 0),
        ("100", 0),
        ("1111", 5),
        ("27", 1),
        ("2525", 4),
        ("10", 1),
        ("7", 1),
        ("0", 0),
        ("1212", 5),
        ("9010", 0),
        ("226", 3),
        ("2101", 1),
        ("30", 0),
    ])
    func examples(message: String, expected: Int) {
        #expect(DigitMessageDecoder.countDecodings(message) == expected)
    }

    @Test("Matches trying every reading on 500 short messages")
    func randomSmall() {
        var random = DigitMessageRandom(seed: 91)
        let digits: [Character] = ["1", "1", "2", "2", "0", "6", "7", "3", "9"]
        for _ in 0..<500 {
            let message = String((0..<Int.random(in: 1...16, using: &random)).map { _ in digits.randomElement(using: &random)! })
            #expect(DigitMessageDecoder.countDecodings(message) == everyReading(message), "message \(message)")
        }
    }

    @Test("Messages of 100,000 digits")
    func large() {
        // A run of n ones (or twos) has fib(n + 1) readings, which is 967,618,232 modulo 1,000,000,007 here
        #expect(DigitMessageDecoder.countDecodings(String(repeating: "1", count: 100_000)) == 967_618_232)
        #expect(DigitMessageDecoder.countDecodings(String(repeating: "2", count: 100_000)) == 967_618_232)
        #expect(DigitMessageDecoder.countDecodings(String(repeating: "12", count: 50_000)) == 967_618_232)
        #expect(DigitMessageDecoder.countDecodings(String(repeating: "10", count: 50_000)) == 1)
        #expect(DigitMessageDecoder.countDecodings(String(repeating: "9", count: 100_000)) == 1)
        #expect(DigitMessageDecoder.countDecodings(String(repeating: "1", count: 50_000) + "00" + String(repeating: "1", count: 49_998)) == 0)
        #expect(DigitMessageDecoder.countDecodings("0" + String(repeating: "1", count: 99_999)) == 0)

        var random = DigitMessageRandom(seed: 100_000)
        let digits: [Character] = ["1", "1", "1", "2", "2", "3", "4", "5", "6", "7", "8", "9"]
        for _ in 0..<3 {
            let message = String((0..<100_000).map { _ in digits.randomElement(using: &random)! })
            #expect(DigitMessageDecoder.countDecodings(message) == fromTheEnd(message))
        }
    }
}
