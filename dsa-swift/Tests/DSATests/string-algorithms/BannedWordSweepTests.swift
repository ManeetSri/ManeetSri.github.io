import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct BannedWordSweepTests {
    /// A tiny deterministic generator, so the random tests do the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    private static func randomText(_ length: Int, from letters: [Character], _ steps: inout Steps) -> String {
        String((0..<length).map { _ in letters[steps.next(below: letters.count)] })
    }

    /// Search for each word separately, trying every start. Fine when everything is short.
    private static func naive(_ words: [String], _ message: String) -> [Int] {
        let t = Array(message.utf8)
        return words.map { word in
            let p = Array(word.utf8)
            guard p.count <= t.count else { return 0 }
            return (0...(t.count - p.count)).filter { t[$0..<($0 + p.count)].elementsEqual(p) }.count
        }
    }

    /// A different method for long messages: for each word length, count every window of that
    /// length in a dictionary, then look each word up.
    private static func viaWindows(_ words: [String], _ message: String) -> [Int] {
        let t = Array(message.utf8)
        var windows: [Int: [ArraySlice<UInt8>: Int]] = [:]
        for length in Set(words.map { $0.utf8.count }) where length <= t.count {
            var counts: [ArraySlice<UInt8>: Int] = [:]
            for start in 0...(t.count - length) { counts[t[start..<(start + length)], default: 0] += 1 }
            windows[length] = counts
        }
        return words.map { word in
            let p = Array(word.utf8)
            return windows[p.count]?[p[...]] ?? 0
        }
    }

    @Test("Examples and edge cases", arguments: [
        (["he", "she", "his", "hers"], "ahishers", [1, 1, 1, 1]),
        (["he", "she", "his", "hers"], "shehershishe", [3, 2, 1, 1]),
        (["a", "aa", "aaa"], "aaaa", [4, 3, 2]),
        (["cat", "cat"], "catcat", [2, 2]),
        (["toolong"], "short", [0]),
        (["ab", "b"], "", [0, 0]),
        ([], "anything", []),
        (["abc", "bca", "cab"], "abcabcab", [2, 2, 2]),
    ] as [([String], String, [Int])])
    func examples(words: [String], message: String, expected: [Int]) {
        #expect(BannedWordSweep.counts(of: words, in: message) == expected)
    }

    @Test("Matches separate searches on 1,000 random small cases")
    func randomSmall() {
        var steps = Steps(seed: 63)
        for round in 0..<1_000 {
            let letters: [Character] = round % 2 == 0 ? ["a", "b"] : ["a", "b", "c"]
            let words = (0..<(1 + steps.next(below: 6))).map { _ in
                Self.randomText(1 + steps.next(below: 4), from: letters, &steps)
            }
            let message = Self.randomText(steps.next(below: 40), from: letters, &steps)
            #expect(BannedWordSweep.counts(of: words, in: message) == Self.naive(words, message))
        }
    }

    @Test("400 nested words in 100,000 a's: about 40 million matches to count")
    func nestedWords() {
        let words = (1...400).map { String(repeating: "a", count: $0) }
        let message = String(repeating: "a", count: 100_000)
        #expect(BannedWordSweep.counts(of: words, in: message) == (1...400).map { 100_001 - $0 })
    }

    @Test("3,000 random words in a random message of 50,000 letters")
    func manyWords() {
        var steps = Steps(seed: 2_024)
        let letters: [Character] = ["a", "b", "c"]
        var words = (0..<3_000).map { _ in Self.randomText(3 + steps.next(below: 6), from: letters, &steps) }
        words += words.prefix(50)                                       // some words appear twice
        let message = Self.randomText(50_000, from: letters, &steps)
        #expect(BannedWordSweep.counts(of: words, in: message) == Self.viaWindows(words, message))
    }
}
