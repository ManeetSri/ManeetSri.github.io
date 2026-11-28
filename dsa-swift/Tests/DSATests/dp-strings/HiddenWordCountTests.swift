import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct HiddenWordRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct HiddenWordCountTests {
    private let modulus = 1_000_000_007

    /// Plain recursion: skip text[i], or use it when it matches word[j]
    private func brute(_ t: [Character], _ w: [Character], _ i: Int, _ j: Int) -> Int {
        if j == w.count { return 1 }
        if i == t.count { return 0 }
        return brute(t, w, i + 1, j) + (t[i] == w[j] ? brute(t, w, i + 1, j + 1) : 0)
    }

    /// C(n, k) modulo 1,000,000,007 from Pascal's triangle: picking k a's out of n a's
    private func binomial(_ n: Int, _ k: Int) -> Int {
        var row = [Int](repeating: 0, count: k + 1)
        row[0] = 1
        for _ in 0..<n {
            for j in stride(from: k, through: 1, by: -1) {
                row[j] = (row[j] + row[j - 1]) % modulus
            }
        }
        return row[k]
    }

    private func randomText(_ alphabet: [Character], _ length: Int, _ random: inout HiddenWordRandom) -> String {
        String((0..<length).map { _ in alphabet[Int.random(in: 0..<alphabet.count, using: &random)] })
    }

    @Test("Examples and small cases", arguments: [
        ("banana", "ban", 3),
        ("banana", "ana", 4),
        ("banana", "nab", 0),
        ("aaaa", "aa", 6),
        ("swift", "", 1),
        ("", "", 1),
        ("", "a", 0),
        ("abc", "abcd", 0),
        ("swift", "swift", 1),
        ("mississippi", "issi", 15),
    ])
    func examples(text: String, word: String, expected: Int) {
        #expect(HiddenWordCount.ways(text: text, word: word) == expected)
    }

    @Test("Matches plain recursion on 300 random short cases")
    func randomSmall() {
        var random = HiddenWordRandom(seed: 546)
        for _ in 0..<300 {
            let text = randomText(Array("ab"), Int.random(in: 0...12, using: &random), &random)
            let word = randomText(Array("ab"), Int.random(in: 0...4, using: &random), &random)
            #expect(HiddenWordCount.ways(text: text, word: word) == brute(Array(text), Array(word), 0, 0), "\"\(word)\" in \"\(text)\"")
        }
    }

    @Test("Counts too big for an Int come back modulo 1,000,000,007")
    func modulo() {
        // C(70, 30) is about 5.5 × 10¹⁹, more than Int.max
        #expect(HiddenWordCount.ways(text: String(repeating: "a", count: 70), word: String(repeating: "a", count: 30)) == 709_329_438)
        #expect(HiddenWordCount.ways(text: String(repeating: "ab", count: 1_000), word: "abab") == 41_749_958_250 % modulus)
    }

    @Test("3,000 letters and a 1,000-letter word")
    func long() {
        let text = String(repeating: "a", count: 3_000)
        let word = String(repeating: "a", count: 1_000)
        #expect(HiddenWordCount.ways(text: text, word: word) == binomial(3_000, 1_000))
        // Every a comes before every b, so an "a…ab…b" word picks its a's and b's separately
        let split = String(repeating: "a", count: 1_500) + String(repeating: "b", count: 1_500)
        let product = binomial(1_500, 400) * binomial(1_500, 600) % modulus
        let target = String(repeating: "a", count: 400) + String(repeating: "b", count: 600)
        #expect(HiddenWordCount.ways(text: split, word: target) == product)
        #expect(HiddenWordCount.ways(text: split, word: "ba") == 0)
    }
}
