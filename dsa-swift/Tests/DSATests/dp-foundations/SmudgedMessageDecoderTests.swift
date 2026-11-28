import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct SmudgedMessageRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct SmudgedMessageDecoderTests {
    private let modulus = 1_000_000_007

    /// The number of decodings of a message with no smudges, by trying every cut
    private func readings(_ digits: [Int]) -> Int {
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

    /// Fill in the smudges every possible way, and add up the decodings of each result
    private func everyFilling(_ message: String) -> Int {
        var digits = message.map { $0.wholeNumberValue ?? -1 }
        let smudges = digits.indices.filter { digits[$0] == -1 }
        func fill(_ k: Int) -> Int {
            if k == smudges.count {
                return readings(digits)
            }
            var total = 0
            for digit in 0...9 {
                digits[smudges[k]] = digit
                total += fill(k + 1)
            }
            return total
        }
        return fill(0)
    }

    /// The same count, filled from the end. How many readings of each character (or pair of characters)
    /// make a letter is found by trying every digit, once per kind of character, and remembered.
    private func fromTheEnd(_ message: String) -> Int {
        let kinds = message.map { $0 == "?" ? 10 : $0.wholeNumberValue! }   // 0-9 for a digit, 10 for a smudge
        let options = (0...10).map { $0 == 10 ? Array(0...9) : [$0] }
        let alone = options.map { $0.filter { (1...9).contains($0) }.count }
        let together = options.map { tens in
            options.map { units in tens.flatMap { t in units.map { t * 10 + $0 } }.filter { (10...26).contains($0) }.count }
        }
        let n = kinds.count
        var ways = Array(repeating: 0, count: n + 2)
        ways[n] = 1
        for i in stride(from: n - 1, through: 0, by: -1) {
            ways[i] = alone[kinds[i]] * ways[i + 1] % modulus
            if i + 1 < n {
                ways[i] = (ways[i] + together[kinds[i]][kinds[i + 1]] * ways[i + 2]) % modulus
            }
        }
        return ways[0]
    }

    @Test("Examples and small cases", arguments: [
        ("?", 9),
        ("1?", 19),
        ("??", 98),
        ("?0", 2),
        ("0?", 0),
        ("2?6", 18),
        ("3?", 9),
        ("?1?", 189),
        ("1?0?", 18),
        ("2611", 4),
        ("100", 0),
    ])
    func examples(message: String, expected: Int) {
        #expect(SmudgedMessageDecoder.countDecodings(message) == expected)
    }

    @Test("Matches filling in every smudge on 150 short messages")
    func randomSmall() {
        var random = SmudgedMessageRandom(seed: 639)
        let characters: [Character] = ["1", "2", "0", "6", "7", "3", "?"]
        for _ in 0..<150 {
            var message = (0..<Int.random(in: 1...9, using: &random)).map { _ in characters.randomElement(using: &random)! }
            // Keep at most three smudges, so filling them in stays quick
            var smudges = 0
            for i in message.indices where message[i] == "?" {
                smudges += 1
                if smudges > 3 {
                    message[i] = "1"
                }
            }
            let text = String(message)
            #expect(SmudgedMessageDecoder.countDecodings(text) == everyFilling(text), "message \(text)")
        }
    }

    @Test("Messages of 100,000 characters")
    func large() {
        // With no smudges it's ordinary decoding: a run of ones has fib(n + 1) readings
        #expect(SmudgedMessageDecoder.countDecodings(String(repeating: "1", count: 100_000)) == 967_618_232)
        // Each "?0" block must read as 10 or 20, independently: 2^50,000 in all
        #expect(SmudgedMessageDecoder.countDecodings(String(repeating: "?0", count: 50_000)) == 18_165_451)
        #expect(SmudgedMessageDecoder.countDecodings("0" + String(repeating: "?", count: 99_999)) == 0)
        let allSmudged = String(repeating: "?", count: 100_000)
        #expect(SmudgedMessageDecoder.countDecodings(allSmudged) == fromTheEnd(allSmudged))

        var random = SmudgedMessageRandom(seed: 100_000)
        let characters: [Character] = ["1", "2", "?", "?", "0", "3", "5", "6", "8"]
        let message = String((0..<100_000).map { _ in characters.randomElement(using: &random)! })
        #expect(SmudgedMessageDecoder.countDecodings(message) == fromTheEnd(message))
    }
}
