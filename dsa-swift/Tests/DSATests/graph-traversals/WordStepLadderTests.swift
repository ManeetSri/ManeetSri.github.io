import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct WordStepLadderTests {
    private let alphabet = Array("abcdefghijklmnopqrstuvwxyz")

    /// aa, ba, bb, cb, cc, … zz, each followed by `suffix`: a path of 51 words where only
    /// neighbours in the list differ by one letter, so the shortest ladder takes all 50 steps
    private func staircase(suffix: String) -> [String] {
        var words = ["aa" + suffix]
        for index in 1..<26 {
            words.append("\(alphabet[index])\(alphabet[index - 1])" + suffix)
            words.append("\(alphabet[index])\(alphabet[index])" + suffix)
        }
        return words
    }

    @Test("Finds the fewest steps", arguments: [
        ("cold", "warm", ["cord", "card", "ward", "warm", "worm", "word", "wore", "core"], 4),
        ("lead", "gold", ["load", "goad", "gold", "lend", "bold"], 3),
        ("ape", "man", ["apt", "opt", "oat", "mat", "man"], 5),
        ("a", "c", ["b", "c"], 1),
        ("aa", "bb", ["aa", "ab", "bb"], 2),
        ("mice", "rats", ["rice", "rite", "rate", "rats", "mite", "mate", "male", "rale", "rile"], 4),
    ])
    func examples(start: String, target: String, words: [String], expected: Int) {
        #expect(WordStepLadder.fewestSteps(from: start, to: target, words: words) == expected)
    }

    @Test("No ladder exists", arguments: [
        ("cat", "dog", ["bat", "bag", "dog"]),
        ("abc", "xyz", ["abd", "abz"]),
        ("ship", "shop", ["chip", "shot"]),
        ("aaa", "bbb", [String]()),
    ])
    func impossible(start: String, target: String, words: [String]) {
        #expect(WordStepLadder.fewestSteps(from: start, to: target, words: words) == -1)
    }

    @Test("Start and target the same needs no steps")
    func sameWord() {
        #expect(WordStepLadder.fewestSteps(from: "same", to: "same", words: []) == 0)
        #expect(WordStepLadder.fewestSteps(from: "same", to: "same", words: ["same", "sane"]) == 0)
    }

    @Test("A staircase of 50 steps with no shortcuts")
    func staircaseLadder() {
        let words = staircase(suffix: "")
        #expect(WordStepLadder.fewestSteps(from: "aa", to: "zz", words: words) == 50)
        #expect(WordStepLadder.fewestSteps(from: "zz", to: "aa", words: words.shuffledDeterministically()) == 50)
    }

    @Test("50 steps hidden among 30,000 other words")
    func largeDictionary() {
        // Comparing every pair of 30,000 words is about 450 million comparisons. The extra words
        // never end in "z", so they can't join the staircase, which always ends in "zzz".
        var seed: UInt64 = 2_024
        func letter(_ count: Int) -> Character {
            seed = seed &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
            return alphabet[Int((seed >> 33) % UInt64(count))]
        }
        var seen = Set<String>()
        var words: [String] = []
        while words.count < 30_000 {
            let word = String([letter(26), letter(26), letter(25), letter(25), letter(25)])
            if seen.insert(word).inserted { words.append(word) }
        }
        words += staircase(suffix: "zzz")
        #expect(WordStepLadder.fewestSteps(from: "aazzz", to: "zzzzz", words: words) == 50)
        #expect(WordStepLadder.fewestSteps(from: "aazzz", to: words[0], words: words) == -1)
    }

    @Test("Every 4-letter word from 8 letters")
    func denseDictionary() {
        let letters = Array("abcdefgh")
        var words: [String] = []
        for a in letters { for b in letters { for c in letters { for d in letters { words.append(String([a, b, c, d])) } } } }
        #expect(WordStepLadder.fewestSteps(from: "aaaa", to: "hhhh", words: words) == 4)
        #expect(WordStepLadder.fewestSteps(from: "abcd", to: "abch", words: words) == 1)
        #expect(WordStepLadder.fewestSteps(from: "zzzz", to: "abcd", words: words) == -1)
    }
}

private extension Array {
    /// The same elements in a fixed scrambled order: every 7th, starting from each offset in turn
    func shuffledDeterministically() -> [Element] {
        (0..<7).flatMap { offset in stride(from: offset, to: count, by: 7).map { self[$0] } }
    }
}
