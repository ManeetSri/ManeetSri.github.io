import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct SharedSubsequenceRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct LongestSharedSubsequenceTests {
    /// Plain recursion over the two prefixes: exponential, but clearly right on short strings
    private func bruteLength(_ a: [Character], _ b: [Character], _ i: Int, _ j: Int) -> Int {
        if i == 0 || j == 0 { return 0 }
        if a[i - 1] == b[j - 1] { return bruteLength(a, b, i - 1, j - 1) + 1 }
        return max(bruteLength(a, b, i - 1, j), bruteLength(a, b, i, j - 1))
    }

    /// A separate two-row table over bytes, for strings too long for the recursion
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
        return previous[b.count]
    }

    private func isSubsequence(_ small: String, of big: String) -> Bool {
        var remaining = small[...]
        for character in big where character == remaining.first {
            remaining = remaining.dropFirst()
        }
        return remaining.isEmpty
    }

    /// Checks oneLongest's answer by its properties, since several answers can be right
    private func checkOneLongest(_ first: String, _ second: String, expected: Int) {
        let answer = LongestSharedSubsequence.oneLongest(first, second)
        #expect(answer.count == expected, "length of \"\(answer)\" for \"\(first)\" and \"\(second)\"")
        #expect(isSubsequence(answer, of: first), "\"\(answer)\" isn't a subsequence of \"\(first)\"")
        #expect(isSubsequence(answer, of: second), "\"\(answer)\" isn't a subsequence of \"\(second)\"")
    }

    private func randomText(_ alphabet: [Character], _ length: Int, _ random: inout SharedSubsequenceRandom) -> String {
        String((0..<length).map { _ in alphabet[Int.random(in: 0..<alphabet.count, using: &random)] })
    }

    @Test("Examples and small cases", arguments: [
        ("ABCBDAB", "BDCABA", 4),
        ("SWIFTLY", "SHIFTILY", 6),
        ("abcde", "ace", 3),
        ("abc", "abc", 3),
        ("abc", "def", 0),
        ("", "abc", 0),
        ("abc", "", 0),
        ("", "", 0),
        ("aaaa", "aa", 2),
        ("café", "cafe", 3),
        ("xyz", "zyx", 1),
    ])
    func examples(first: String, second: String, expected: Int) {
        #expect(LongestSharedSubsequence.length(first, second) == expected)
        checkOneLongest(first, second, expected: expected)
    }

    @Test("Matches plain recursion on 300 random short pairs")
    func randomSmall() {
        var random = SharedSubsequenceRandom(seed: 54)
        for _ in 0..<300 {
            let first = randomText(Array("abc"), Int.random(in: 0...7, using: &random), &random)
            let second = randomText(Array("abc"), Int.random(in: 0...7, using: &random), &random)
            let expected = bruteLength(Array(first), Array(second), first.count, second.count)
            #expect(LongestSharedSubsequence.length(first, second) == expected, "\"\(first)\" and \"\(second)\"")
            checkOneLongest(first, second, expected: expected)
        }
    }

    @Test("Two random 2,000-character strands")
    func longRandom() {
        var random = SharedSubsequenceRandom(seed: 2_000)
        let first = randomText(Array("ACGT"), 2_000, &random)
        let second = randomText(Array("ACGT"), 2_000, &random)
        let expected = referenceLength(first, second)
        #expect(LongestSharedSubsequence.length(first, second) == expected)
        checkOneLongest(first, second, expected: expected)
    }

    @Test("Long strings with known answers")
    func longPlanted() {
        // Every a comes before every b in the first string and after every b in the second, so a
        // shared subsequence is all a's (at most 300) or all b's (at most 600).
        let first = String(repeating: "a", count: 600) + String(repeating: "b", count: 600)
        let second = String(repeating: "b", count: 900) + String(repeating: "a", count: 300)
        #expect(LongestSharedSubsequence.length(first, second) == 600)
        #expect(LongestSharedSubsequence.oneLongest(first, second) == String(repeating: "b", count: 600))

        var random = SharedSubsequenceRandom(seed: 7)
        let same = randomText(Array("xyz"), 1_200, &random)
        #expect(LongestSharedSubsequence.length(same, same) == 1_200)
        #expect(LongestSharedSubsequence.oneLongest(same, same) == same)
    }
}
