import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same words
private struct TrieRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct FlatArrayTrieTests {
    typealias Trie = FlatArrayTrie.Trie

    @Test("An empty trie is just the root")
    func empty() {
        let trie = Trie()
        #expect(trie.nodeCount == 1)
        #expect(trie.wordCount == 0)
        #expect(!trie.contains("a"))
        #expect(trie.countWords(withPrefix: "") == 0)
        #expect(trie.child(of: 0, letter: "a") == nil)
    }

    @Test("The statement's example, with nodes numbered in creation order")
    func example() {
        var trie = Trie()
        for word in ["car", "cat", "cart", "dog"] {
            trie.insert(word)
        }
        #expect(trie.nodeCount == 9)
        #expect(trie.wordCount == 4)
        #expect(trie.child(of: 0, letter: "c") == 1)
        #expect(trie.child(of: 1, letter: "a") == 2)
        #expect(trie.child(of: 2, letter: "r") == 3)
        #expect(trie.child(of: 2, letter: "t") == 4)
        #expect(trie.child(of: 3, letter: "t") == 5)
        #expect(trie.child(of: 0, letter: "d") == 6)
        #expect(trie.child(of: 6, letter: "o") == 7)
        #expect(trie.child(of: 7, letter: "g") == 8)
        #expect(trie.child(of: 0, letter: "a") == nil)
        #expect(trie.child(of: 4, letter: "s") == nil)
        #expect(trie.contains("cart"))
        #expect(trie.contains("car"))
        #expect(!trie.contains("ca"))
        #expect(!trie.contains("carts"))
        #expect(!trie.contains("do"))
        #expect(trie.countWords(withPrefix: "ca") == 3)
        #expect(trie.countWords(withPrefix: "car") == 2)
        #expect(trie.countWords(withPrefix: "") == 4)
        #expect(trie.countWords(withPrefix: "x") == 0)
        #expect(trie.countWords(withPrefix: "carts") == 0)
    }

    @Test("Inserting a word twice keeps one copy")
    func duplicates() {
        var trie = Trie()
        trie.insert("ant")
        trie.insert("ant")
        #expect(trie.wordCount == 1)
        #expect(trie.countWords(withPrefix: "a") == 1)
        #expect(trie.nodeCount == 4)
    }

    @Test("A word that is a prefix of another")
    func prefixWords() {
        var trie = Trie()
        trie.insert("bee")
        trie.insert("be")
        trie.insert("b")
        #expect(trie.nodeCount == 4, "shorter words reuse existing nodes")
        #expect(trie.contains("b"))
        #expect(trie.contains("be"))
        #expect(trie.countWords(withPrefix: "b") == 3)
        #expect(trie.countWords(withPrefix: "be") == 2)
        #expect(trie.countWords(withPrefix: "bee") == 1)
    }

    @Test("Characters other than a–z have no child")
    func otherCharacters() {
        var trie = Trie()
        trie.insert("a")
        #expect(trie.child(of: 0, letter: "A") == nil)
        #expect(trie.child(of: 0, letter: "é") == nil)
        #expect(trie.child(of: 0, letter: "1") == nil)
        #expect(!trie.contains("A"))
        #expect(trie.countWords(withPrefix: "A") == 0)
    }

    @Test("Copies are independent values")
    func copies() {
        var original = Trie()
        original.insert("swift")
        var copy = original
        copy.insert("swim")
        copy.insert("zebra")
        #expect(!original.contains("swim"))
        #expect(!original.contains("zebra"))
        #expect(original.nodeCount == 6)
        #expect(original.countWords(withPrefix: "sw") == 1)
        #expect(copy.countWords(withPrefix: "sw") == 2)
        original.insert("sweet")
        #expect(!copy.contains("sweet"))
    }

    @Test("40,000 random words match a Set and a prefix count")
    func largeRandom() {
        var random = TrieRandom(seed: 68)
        let letters = Array("abcdef")
        func randomWord(_ length: ClosedRange<Int>) -> String {
            String((0..<Int.random(in: length, using: &random)).map { _ in letters.randomElement(using: &random)! })
        }
        var trie = Trie()
        var words = Set<String>()
        for _ in 0..<40_000 {
            let word = randomWord(1...10)
            trie.insert(word)
            words.insert(word)
        }
        var prefixCounts: [Substring: Int] = [:]
        for word in words {
            for end in word.indices {
                prefixCounts[word[...end], default: 0] += 1
            }
        }
        #expect(trie.wordCount == words.count)
        #expect(trie.nodeCount == prefixCounts.count + 1, "one node per different prefix, plus the root")
        #expect(trie.countWords(withPrefix: "") == words.count)

        var mismatches = 0
        for _ in 0..<20_000 {
            let query = randomWord(1...8)
            if trie.contains(query) != words.contains(query) { mismatches += 1 }
            if trie.countWords(withPrefix: query) != prefixCounts[Substring(query), default: 0] { mismatches += 1 }
        }
        #expect(mismatches == 0)

        // Children are always created after their parents, so ids grow along every path
        for word in words.prefix(500) {
            var node = 0
            for letter in word {
                guard let next = trie.child(of: node, letter: letter) else {
                    Issue.record("missing node on the path of \(word)")
                    return
                }
                #expect(next > node && next < trie.nodeCount)
                node = next
            }
        }
    }
}
