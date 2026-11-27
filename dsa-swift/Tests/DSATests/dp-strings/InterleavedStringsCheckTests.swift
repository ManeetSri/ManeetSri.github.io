import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct InterleaveRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct InterleavedStringsCheckTests {
    /// Plain recursion: take merged's next character from first or from second. Exponential, fine when short.
    private func brute(_ a: [Character], _ b: [Character], _ c: [Character], _ i: Int, _ j: Int) -> Bool {
        if i + j == c.count { return i == a.count && j == b.count }
        if i < a.count && a[i] == c[i + j] && brute(a, b, c, i + 1, j) { return true }
        return j < b.count && b[j] == c[i + j] && brute(a, b, c, i, j + 1)
    }

    /// A separate full table, for strings too long for the recursion
    private func reference(_ first: String, _ second: String, _ merged: String) -> Bool {
        let a = Array(first), b = Array(second), c = Array(merged)
        guard a.count + b.count == c.count else { return false }
        var can = [[Bool]](repeating: [Bool](repeating: false, count: b.count + 1), count: a.count + 1)
        can[0][0] = true
        for i in 0...a.count {
            for j in 0...b.count where i + j > 0 {
                can[i][j] = (i > 0 && can[i - 1][j] && a[i - 1] == c[i + j - 1]) || (j > 0 && can[i][j - 1] && b[j - 1] == c[i + j - 1])
            }
        }
        return can[a.count][b.count]
    }

    /// Weaves the two strings together at random
    private func weave(_ first: String, _ second: String, _ random: inout InterleaveRandom) -> String {
        var a = first[...], b = second[...]
        var result = ""
        while !a.isEmpty || !b.isEmpty {
            if b.isEmpty || (!a.isEmpty && Bool.random(using: &random)) {
                result.append(a.removeFirst())
            } else {
                result.append(b.removeFirst())
            }
        }
        return result
    }

    private func randomText(_ alphabet: [Character], _ length: Int, _ random: inout InterleaveRandom) -> String {
        String((0..<length).map { _ in alphabet[Int.random(in: 0..<alphabet.count, using: &random)] })
    }

    @Test("Examples and small cases", arguments: [
        ("ab", "ac", "acab", true),
        ("ab", "ac", "aabc", true),
        ("ab", "ac", "abca", false),
        ("ab", "ac", "acba", false),
        ("abc", "def", "adbecf", true),
        ("abc", "def", "abdfce", false),
        ("", "", "", true),
        ("abc", "", "abc", true),
        ("", "abc", "abd", false),
        ("a", "b", "abc", false),
        ("a", "b", "", false),
        ("aa", "ab", "abaa", true),
        ("aa", "ab", "baaa", false),
    ])
    func examples(first: String, second: String, merged: String, expected: Bool) {
        #expect(InterleavedStringsCheck.canInterleave(first, second, into: merged) == expected)
    }

    @Test("Matches plain recursion on 1,000 random short cases")
    func randomSmall() {
        var random = InterleaveRandom(seed: 5_410)
        for round in 0..<1_000 {
            let first = randomText(Array("ab"), Int.random(in: 0...5, using: &random), &random)
            let second = randomText(Array("ab"), Int.random(in: 0...5, using: &random), &random)
            // Half real weaves, half random strings of the right length
            let merged = round % 2 == 0 ? weave(first, second, &random) : randomText(Array("ab"), first.count + second.count, &random)
            #expect(InterleavedStringsCheck.canInterleave(first, second, into: merged) == brute(Array(first), Array(second), Array(merged), 0, 0),
                    "\"\(first)\" + \"\(second)\" → \"\(merged)\"")
        }
    }

    @Test("Long strings of one letter, where a wrong guess costs everything")
    func longRepeats() {
        let first = String(repeating: "a", count: 500)
        let second = String(repeating: "a", count: 499) + "b"
        #expect(InterleavedStringsCheck.canInterleave(first, second, into: String(repeating: "a", count: 999) + "b"))
        #expect(InterleavedStringsCheck.canInterleave(first, second, into: String(repeating: "a", count: 998) + "ba"))
        #expect(!InterleavedStringsCheck.canInterleave(first, second, into: String(repeating: "a", count: 999) + "c"))
        #expect(!InterleavedStringsCheck.canInterleave(first, second, into: "b" + String(repeating: "a", count: 999)))
    }

    @Test("Long random weaves, before and after a swap")
    func longRandom() {
        var random = InterleaveRandom(seed: 5_000)
        for _ in 0..<4 {
            let first = randomText(Array("ab"), 500, &random)
            let second = randomText(Array("ab"), 500, &random)
            var merged = Array(weave(first, second, &random))
            #expect(InterleavedStringsCheck.canInterleave(first, second, into: String(merged)))
            // Swapping two different neighbours may or may not break it
            let position = merged.indices.dropLast().first { merged[$0] != merged[$0 + 1] } ?? 0
            merged.swapAt(position, position + 1)
            let swapped = String(merged)
            #expect(InterleavedStringsCheck.canInterleave(first, second, into: swapped) == reference(first, second, swapped))
        }
    }
}
