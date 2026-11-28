import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct SupersequenceRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct ShortestCombinedSupersequenceTests {
    /// Plain recursion on the length: write one string's next character, or a shared one once
    private func bruteLength(_ a: [Character], _ b: [Character], _ i: Int, _ j: Int) -> Int {
        if i == a.count { return b.count - j }
        if j == b.count { return a.count - i }
        if a[i] == b[j] { return 1 + bruteLength(a, b, i + 1, j + 1) }
        return 1 + min(bruteLength(a, b, i + 1, j), bruteLength(a, b, i, j + 1))
    }

    /// For long strings: n + m − LCS, with the LCS from a two-row table over bytes
    private func referenceLength(_ first: String, _ second: String) -> Int {
        let a = Array(first.utf8), b = Array(second.utf8)
        var previous = [Int](repeating: 0, count: b.count + 1)
        var current = previous
        for x in a {
            for j in 1..<(b.count + 1) {
                current[j] = x == b[j - 1] ? previous[j - 1] + 1 : max(previous[j], current[j - 1])
            }
            swap(&previous, &current)
        }
        return a.count + b.count - previous[b.count]
    }

    private func isSubsequence(_ small: String, of big: String) -> Bool {
        var remaining = small[...]
        for character in big where character == remaining.first {
            remaining = remaining.dropFirst()
        }
        return remaining.isEmpty
    }

    /// Several answers can be right, so check the properties: both strings fit inside, and it's as short as possible
    private func check(_ first: String, _ second: String, expectedLength: Int) {
        let answer = ShortestCombinedSupersequence.shortest(first, second)
        #expect(answer.count == expectedLength, "\"\(answer)\" for \"\(first)\" and \"\(second)\" should have \(expectedLength) characters")
        #expect(isSubsequence(first, of: answer), "\"\(first)\" isn't a subsequence of \"\(answer)\"")
        #expect(isSubsequence(second, of: answer), "\"\(second)\" isn't a subsequence of \"\(answer)\"")
    }

    private func randomText(_ alphabet: [Character], _ length: Int, _ random: inout SupersequenceRandom) -> String {
        String((0..<length).map { _ in alphabet[Int.random(in: 0..<alphabet.count, using: &random)] })
    }

    @Test("Examples and small cases", arguments: [
        ("abac", "cab", 5),
        ("swift", "shift", 6),
        ("geek", "eke", 5),
        ("abc", "def", 6),
        ("aaa", "aaa", 3),
        ("", "xyz", 3),
        ("xyz", "", 3),
        ("", "", 0),
        ("ab", "ba", 3),
        ("café", "cafe", 5),
    ])
    func examples(first: String, second: String, expectedLength: Int) {
        check(first, second, expectedLength: expectedLength)
    }

    @Test("Answers that are forced")
    func forced() {
        #expect(ShortestCombinedSupersequence.shortest("swift", "swift") == "swift")
        #expect(ShortestCombinedSupersequence.shortest("", "ios") == "ios")
        #expect(ShortestCombinedSupersequence.shortest("abc", "b") == "abc")
    }

    @Test("Matches the brute-force length on 300 random short pairs")
    func randomSmall() {
        var random = SupersequenceRandom(seed: 545)
        for _ in 0..<300 {
            let first = randomText(Array("abc"), Int.random(in: 0...7, using: &random), &random)
            let second = randomText(Array("abc"), Int.random(in: 0...7, using: &random), &random)
            check(first, second, expectedLength: bruteLength(Array(first), Array(second), 0, 0))
        }
    }

    @Test("Two random 1,500-character strings")
    func longRandom() {
        var random = SupersequenceRandom(seed: 1_501)
        let first = randomText(Array("abcd"), 1_500, &random)
        let second = randomText(Array("abcd"), 1_500, &random)
        check(first, second, expectedLength: referenceLength(first, second))
    }

    @Test("Long strings with known answers")
    func longPlanted() {
        let first = String(repeating: "a", count: 1_000)
        let second = String(repeating: "b", count: 800)
        check(first, second, expectedLength: 1_800)
        let mixed = String(repeating: "ab", count: 700)
        check(mixed, "b" + mixed, expectedLength: 1_401)
    }
}
