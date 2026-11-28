import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct WordRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct WordGrowthChainTests {
    /// Does `longer` come from `shorter` by inserting exactly one letter? Walks both words together and
    /// allows one skip in the longer word.
    private func grows(_ shorter: [Character], into longer: [Character]) -> Bool {
        guard longer.count == shorter.count + 1 else { return false }
        var i = 0
        var skipped = false
        for letter in longer {
            if i < shorter.count && shorter[i] == letter {
                i += 1
            } else if skipped {
                return false
            } else {
                skipped = true
            }
        }
        return true
    }

    /// The O(n²) chain DP, comparing every pair of words directly
    private func reference(_ words: [String]) -> Int {
        let sorted = words.map { Array($0) }.sorted { $0.count < $1.count }
        var chain = Array(repeating: 1, count: sorted.count)
        for i in sorted.indices {
            for j in 0..<i where grows(sorted[j], into: sorted[i]) {
                chain[i] = max(chain[i], chain[j] + 1)
            }
        }
        return chain.max() ?? 0
    }

    private func randomWord(length: Int, letters: [Character], using random: inout WordRandom) -> String {
        String((0..<length).map { _ in letters.randomElement(using: &random)! })
    }

    @Test("Examples and edge cases", arguments: [
        (["chart", "a", "cat", "dog", "at", "cart", "do", "chat", "art"], 5),
        (["abc", "ab", "b", "a", "bc"], 3),
        (["x", "xx", "xxx", "xx"], 3),
        (["a", "abc"], 1),
        (["dog", "god"], 1),
        (["ab", "ba"], 1),
        (["boned", "on", "one", "o", "bone", "bond"], 5),
        (["solo"], 1),
        ([], 0),
    ] as [([String], Int)])
    func examples(words: [String], expected: Int) {
        #expect(WordGrowthChain.longestChain(words) == expected)
    }

    @Test("Matches the pairwise DP on 300 small word lists")
    func randomSmall() {
        var random = WordRandom(seed: 57)
        let letters: [Character] = ["a", "b", "c"]
        for _ in 0..<300 {
            let words = (0..<Int.random(in: 0...25, using: &random)).map { _ in
                randomWord(length: Int.random(in: 1...5, using: &random), letters: letters, using: &random)
            }
            #expect(WordGrowthChain.longestChain(words) == reference(words), "words: \(words)")
        }
    }

    @Test("Matches the pairwise DP on 600 words")
    func medium() {
        var random = WordRandom(seed: 600)
        let letters: [Character] = ["a", "b"]
        let words = (0..<600).map { _ in
            randomWord(length: Int.random(in: 1...9, using: &random), letters: letters, using: &random)
        }
        #expect(WordGrowthChain.longestChain(words) == reference(words))
    }

    @Test("20,000 words with a planted chain of 13")
    func large() {
        var random = WordRandom(seed: 20_000)
        // Filler words use only a...m and have 10 to 16 letters, so any chain among them has at most 7.
        let filler = Array("abcdefghijklm")
        var words = (0..<19_987).map { _ in
            randomWord(length: Int.random(in: 10...16, using: &random), letters: filler, using: &random)
        }
        // The planted chain uses only n...z, so it can't mix with the filler. Each word inserts one
        // random letter at a random place in the one before.
        let planted = Array("nopqrstuvwxyz")
        var word: [Character] = [planted.randomElement(using: &random)!]
        words.append(String(word))
        for _ in 1..<13 {
            word.insert(planted.randomElement(using: &random)!, at: Int.random(in: 0...word.count, using: &random))
            words.append(String(word))
        }
        words.shuffle(using: &random)
        #expect(WordGrowthChain.longestChain(words) == 13)
    }
}
