import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct DisjointLetterWordsTests {
    // Compares the words character by character, for small inputs
    static func slowBest(_ words: [String]) -> Int {
        var best = 0
        for i in 0..<words.count {
            for j in (i + 1)..<words.count where Set(words[i]).isDisjoint(with: Set(words[j])) {
                best = max(best, words[i].count * words[j].count)
            }
        }
        return best
    }

    @Test("Symbol sets", arguments: [
        ("", UInt64(0)), ("a", 1), ("ba", 3), ("aaa", 1), ("z", 1 << 25), ("A", 1 << 26), ("Z", 1 << 51),
        ("0", 1 << 52), ("9", 1 << 61), ("aA0", 1 | 1 << 26 | 1 << 52),
    ])
    func symbolSets(word: String, expected: UInt64) {
        #expect(DisjointLetterWords.symbolSet(word) == expected)
    }

    @Test("All 62 symbols fill bits 0 to 61")
    func allSymbols() {
        let everything = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        #expect(DisjointLetterWords.symbolSet(everything) == (1 << 62) - 1)
        #expect(DisjointLetterWords.symbolSet(everything).nonzeroBitCount == 62)
    }

    @Test("Best product examples")
    func examples() {
        #expect(DisjointLetterWords.bestProduct(["stack", "queue", "heap", "trie", "graph"]) == 25)
        #expect(DisjointLetterWords.bestProduct(["zebra", "MOON", "42"]) == 20)
        #expect(DisjointLetterWords.bestProduct(["aa", "AA", "a1"]) == 4)
        #expect(DisjointLetterWords.bestProduct(["abc", "cab", "bca"]) == 0)
    }

    @Test("Too few words, empty words and repeated words")
    func edges() {
        #expect(DisjointLetterWords.bestProduct([]) == 0)
        #expect(DisjointLetterWords.bestProduct(["swift"]) == 0)
        #expect(DisjointLetterWords.bestProduct(["", "swift"]) == 0)
        #expect(DisjointLetterWords.bestProduct(["swift", "swift"]) == 0)
        #expect(DisjointLetterWords.bestProduct(["ab", "cd", "ab"]) == 4)
        #expect(DisjointLetterWords.bestProduct(["Zz9", "zz", "Z", "99"]) == 4)
    }

    @Test("Matches comparing letter by letter on mixed word lists")
    func matchesSlow() {
        let symbols = Array("abcdefgABCDE0123")
        var seed = 31
        for round in 0..<60 {
            let words = (0..<(round % 15)).map { _ -> String in
                seed = (seed * 1_103_515_245 + 12_345) % 2_147_483_648
                let length = seed % 6
                return String((0..<length).map { _ -> Character in
                    seed = (seed * 1_103_515_245 + 12_345) % 2_147_483_648
                    return symbols[seed % symbols.count]
                })
            }
            #expect(DisjointLetterWords.bestProduct(words) == Self.slowBest(words), "words \(words)")
        }
    }

    @Test("Two thousand words of 100 symbols")
    func large() {
        // word i repeats the two symbols i % 62 and (i + 1) % 62, so words sharing a symbol are neighbours
        let symbols = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        var words = (0..<2_000).map { i in
            String(repeating: String([symbols[i % 62], symbols[(i + 1) % 62]]), count: 50)
        }
        #expect(DisjointLetterWords.bestProduct(words) == 10_000)
        words = (0..<2_000).map { _ in "a" + String(repeating: "b", count: 99) }
        #expect(DisjointLetterWords.bestProduct(words) == 0)
    }
}
