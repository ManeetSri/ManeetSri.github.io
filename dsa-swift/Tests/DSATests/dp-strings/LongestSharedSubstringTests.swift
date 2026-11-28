import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct SharedSubstringRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct LongestSharedSubstringTests {
    /// Tries every length from longest down, and every start in `first` from left to right
    private func brute(_ first: String, _ second: String) -> String {
        let a = Array(first)
        for length in stride(from: min(first.count, second.count), through: 1, by: -1) {
            for start in 0...(a.count - length) {
                let piece = String(a[start..<(start + length)])
                if second.contains(piece) {
                    return piece
                }
            }
        }
        return ""
    }

    private func randomText(_ alphabet: [Character], _ length: Int, _ random: inout SharedSubstringRandom) -> String {
        String((0..<length).map { _ in alphabet[Int.random(in: 0..<alphabet.count, using: &random)] })
    }

    @Test("Examples and small cases", arguments: [
        ("photograph", "tomography", "ograph"),
        ("ABAB", "BABA", "ABA"),
        ("swift", "shift", "ift"),
        ("abcdxyz", "xyzabcd", "abcd"),
        ("abc", "xyz", ""),
        ("", "abc", ""),
        ("abc", "", ""),
        ("aaa", "aa", "aa"),
        ("ab", "ba", "a"),
        ("xyab", "abxy", "xy"),
        ("same", "same", "same"),
        ("naïve", "naive", "na"),
    ])
    func examples(first: String, second: String, expected: String) {
        #expect(LongestSharedSubstring.longest(first, second) == expected)
    }

    @Test("Matches the brute force on 400 random short pairs")
    func randomSmall() {
        var random = SharedSubstringRandom(seed: 541)
        for round in 0..<400 {
            let alphabet = Array(round % 2 == 0 ? "ab" : "abc")
            let first = randomText(alphabet, Int.random(in: 0...9, using: &random), &random)
            let second = randomText(alphabet, Int.random(in: 0...9, using: &random), &random)
            #expect(LongestSharedSubstring.longest(first, second) == brute(first, second), "\"\(first)\" and \"\(second)\"")
        }
    }

    @Test("A 60-character block hidden in two 2,000-character strings")
    func longPlanted() {
        // The second string uses other letters everywhere except the block, so every shared run lies
        // inside the block, and the block itself is the only one of length 60.
        var random = SharedSubstringRandom(seed: 60)
        let block = randomText(Array("abcdefgh"), 60, &random)
        let first = randomText(Array("abcdefgh"), 1_200, &random) + block + randomText(Array("abcdefgh"), 740, &random)
        let second = randomText(Array("stuvwxyz"), 300, &random) + block + randomText(Array("stuvwxyz"), 1_640, &random)
        #expect(LongestSharedSubstring.longest(first, second) == block)
    }

    @Test("Long repeated letters")
    func longRepeats() {
        let a1500 = String(repeating: "a", count: 1_500)
        let a1000 = String(repeating: "a", count: 1_000)
        #expect(LongestSharedSubstring.longest(a1500, a1000) == a1000)
        #expect(LongestSharedSubstring.longest(a1000 + "b" + a1000, a1500) == a1000)
        let pattern = String(repeating: "ab", count: 1_000)
        #expect(LongestSharedSubstring.longest(pattern, "b" + pattern) == pattern)
    }
}
