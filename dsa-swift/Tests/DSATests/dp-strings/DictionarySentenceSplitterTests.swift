import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct SentenceSplitRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct DictionarySentenceSplitterTests {
    /// Plain backtracking with no memo: try every word that starts here. Exponential, fine when short.
    private func bruteSentences(_ text: [Character], _ start: Int, _ words: [String]) -> [String] {
        if start == text.count { return [""] }
        var result: [String] = []
        for word in Set(words) where !word.isEmpty && start + word.count <= text.count
            && String(text[start..<(start + word.count)]) == word {
            for rest in bruteSentences(text, start + word.count, words) {
                result.append(rest.isEmpty ? word : word + " " + rest)
            }
        }
        return result
    }

    /// A sentence is right if its words are all in the dictionary and spell the text
    private func isValid(_ sentence: String, _ text: String, _ dictionary: Set<String>) -> Bool {
        let pieces = sentence.split(separator: " ", omittingEmptySubsequences: false).map(String.init)
        return pieces.joined() == text && pieces.allSatisfy { dictionary.contains($0) }
    }

    private func randomText(_ alphabet: [Character], _ length: Int, _ random: inout SentenceSplitRandom) -> String {
        String((0..<length).map { _ in alphabet[Int.random(in: 0..<alphabet.count, using: &random)] })
    }

    @Test("Can it be split? Examples", arguments: [
        ("icecreamcone", ["ice", "cream", "icecream", "cone", "con"], true),
        ("creamicecon", ["ice", "cream", "icecream", "cone", "con"], true),
        ("icecreamcones", ["ice", "cream", "icecream", "cone", "con"], false),
        ("nowhere", ["no", "now", "where", "here", "w", "he", "re"], true),
        ("aaaaaaa", ["aaaa", "aaa"], true),
        ("aaaaaaa", ["aaaa", "aa"], false),
        ("swift", ["swift"], true),
        ("swift", [], false),
    ])
    func canSplitExamples(text: String, words: [String], expected: Bool) {
        #expect(DictionarySentenceSplitter.canSplit(text, words: words) == expected)
    }

    @Test("Every sentence: examples")
    func allSentencesExamples() {
        let found = DictionarySentenceSplitter.allSentences("nowhere", words: ["no", "now", "where", "here", "w", "he", "re"]).sorted()
        #expect(found == ["no w he re", "no w here", "no where", "now he re", "now here"])
        #expect(DictionarySentenceSplitter.allSentences("icecreamcone", words: ["ice", "cream", "icecream", "cone", "con"]).sorted()
                == ["ice cream cone", "icecream cone"])
        #expect(DictionarySentenceSplitter.allSentences("icecreamcones", words: ["ice", "cream", "icecream", "cone"]).isEmpty)
        #expect(DictionarySentenceSplitter.allSentences("swift", words: ["swift", "sw", "ift"]).sorted() == ["sw ift", "swift"])
        #expect(DictionarySentenceSplitter.allSentences("aaa", words: ["a", "aa"]).sorted() == ["a a a", "a aa", "aa a"])
    }

    @Test("Matches plain backtracking on 300 random short cases")
    func randomSmall() {
        var random = SentenceSplitRandom(seed: 549)
        for _ in 0..<300 {
            let words = (0..<Int.random(in: 1...5, using: &random)).map { _ in
                randomText(Array("ab"), Int.random(in: 1...3, using: &random), &random)
            }
            let text = randomText(Array("ab"), Int.random(in: 1...10, using: &random), &random)
            let expected = bruteSentences(Array(text), 0, words).sorted()
            #expect(DictionarySentenceSplitter.canSplit(text, words: words) == !expected.isEmpty, "\"\(text)\" with \(words)")
            #expect(DictionarySentenceSplitter.allSentences(text, words: words).sorted() == expected, "\"\(text)\" with \(words)")
        }
    }

    @Test("Long texts where plain recursion never finishes")
    func longCanSplit() {
        let words = ["a", "aa", "aaa", "aaaa", "aaaaa"]
        #expect(!DictionarySentenceSplitter.canSplit(String(repeating: "a", count: 999) + "b", words: words))
        #expect(DictionarySentenceSplitter.canSplit(String(repeating: "a", count: 1_000), words: words))

        var random = SentenceSplitRandom(seed: 1_000)
        let dictionary = (0..<300).map { _ in randomText(Array("abc"), Int.random(in: 3...20, using: &random), &random) }
        var text = ""
        while text.count < 980 {
            text += dictionary[Int.random(in: 0..<dictionary.count, using: &random)]
        }
        #expect(DictionarySentenceSplitter.canSplit(text, words: dictionary))
        #expect(!DictionarySentenceSplitter.canSplit(text + "d", words: dictionary))
    }

    @Test("Exponentially many sentences")
    func manySentences() {
        // Splitting n a's into "a" and "aa" can be done in Fibonacci(n + 1) ways
        let text = String(repeating: "a", count: 20)
        let found = DictionarySentenceSplitter.allSentences(text, words: ["a", "aa"])
        #expect(found.count == 10_946)
        #expect(Set(found).count == found.count)
        #expect(found.allSatisfy { isValid($0, text, ["a", "aa"]) })
    }

    @Test("No sentences, found quickly")
    func deadEnds() {
        // Plain backtracking tries every split of the a's before failing at the b; a memo fails fast
        let text = String(repeating: "a", count: 500) + "b"
        #expect(DictionarySentenceSplitter.allSentences(text, words: ["a", "aa", "aaa"]).isEmpty)
    }
}
