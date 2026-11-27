import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct CountingTrieDesignTests {
    typealias CountingTrie = CountingTrieDesign.CountingTrie

    /// A tiny deterministic generator, so the random tests do the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    @Test("The example from the statement")
    func example() {
        let trie = CountingTrie()
        trie.insert("apple")
        trie.insert("apple")
        trie.insert("app")
        #expect(trie.count(of: "apple") == 2)
        #expect(trie.count(withPrefix: "app") == 3)
        #expect(trie.remove("apple") == true)
        #expect(trie.count(of: "apple") == 1)
        #expect(trie.count(withPrefix: "app") == 2)
        #expect(trie.remove("apple") == true)
        #expect(trie.remove("apple") == false)
        #expect(trie.nodeCount == 3)
    }

    @Test("A new trie is empty")
    func empty() {
        let trie = CountingTrie()
        #expect(trie.count(of: "a") == 0)
        #expect(trie.count(withPrefix: "a") == 0)
        #expect(trie.count(withPrefix: "") == 0)
        #expect(trie.remove("a") == false)
        #expect(trie.nodeCount == 0)
    }

    @Test("Prefix counts include every copy, and the empty prefix counts everything")
    func prefixCounts() {
        let trie = CountingTrie()
        for word in ["tea", "tea", "ten", "to", "inn", "in", "tea"] {
            trie.insert(word)
        }
        #expect(trie.count(of: "tea") == 3)
        #expect(trie.count(of: "te") == 0)
        #expect(trie.count(withPrefix: "t") == 5)
        #expect(trie.count(withPrefix: "te") == 4)
        #expect(trie.count(withPrefix: "tea") == 3)
        #expect(trie.count(withPrefix: "teas") == 0)
        #expect(trie.count(withPrefix: "in") == 2)
        #expect(trie.count(withPrefix: "") == 7)
        #expect(trie.nodeCount == 8)                      // t, te, tea, ten, to, i, in, inn
    }

    @Test("Removal prunes branches that no word uses")
    func pruning() {
        let trie = CountingTrie()
        for word in ["cart", "car", "cat", "dog"] {
            trie.insert(word)
        }
        #expect(trie.nodeCount == 8)
        #expect(trie.remove("cart"))
        #expect(trie.nodeCount == 7)
        #expect(trie.count(withPrefix: "cart") == 0)
        #expect(trie.remove("dog"))
        #expect(trie.nodeCount == 4)
        #expect(trie.count(withPrefix: "d") == 0)
        #expect(trie.remove("car"))
        #expect(trie.nodeCount == 3)
        #expect(trie.remove("cat"))
        #expect(trie.nodeCount == 0)
        #expect(trie.count(withPrefix: "") == 0)
        trie.insert("cab")
        #expect(trie.nodeCount == 3)
        #expect(trie.count(withPrefix: "ca") == 1)
    }

    @Test("A word that's a prefix of another keeps the shared nodes")
    func removingAPrefixWord() {
        let trie = CountingTrie()
        trie.insert("an")
        trie.insert("ant")
        #expect(trie.remove("an"))
        #expect(trie.nodeCount == 3)
        #expect(trie.count(of: "an") == 0)
        #expect(trie.count(of: "ant") == 1)
        #expect(trie.count(withPrefix: "an") == 1)
    }

    @Test("Removing something that isn't stored changes nothing")
    func removingMissing() {
        let trie = CountingTrie()
        trie.insert("planet")
        #expect(trie.remove("plan") == false)              // a prefix, not a word
        #expect(trie.remove("planets") == false)
        #expect(trie.remove("x") == false)
        #expect(trie.nodeCount == 6)
        #expect(trie.count(withPrefix: "p") == 1)
        #expect(trie.count(of: "planet") == 1)
    }

    @Test("30,000 random operations agree with a dictionary of counts")
    func randomOperations() {
        var steps = Steps(seed: 2_024)
        let letters = Array("abc")
        func randomWord() -> String {
            String((0...steps.next(below: 5)).map { _ in letters[steps.next(below: letters.count)] })
        }
        let trie = CountingTrie()
        var model: [String: Int] = [:]
        var mismatches = 0
        for step in 0..<30_000 {
            let word = randomWord()
            switch steps.next(below: 4) {
            case 0, 1:
                trie.insert(word)
                model[word, default: 0] += 1
            case 2:
                let stored = model[word, default: 0]
                if trie.remove(word) != (stored > 0) { mismatches += 1 }
                if stored > 1 { model[word] = stored - 1 } else { model[word] = nil }
            default:
                if trie.count(of: word) != model[word, default: 0] { mismatches += 1 }
                let prefix = String(word.prefix(steps.next(below: word.count + 1)))
                let expected = model.reduce(0) { $1.key.hasPrefix(prefix) ? $0 + $1.value : $0 }
                if trie.count(withPrefix: prefix) != expected { mismatches += 1 }
            }
            if step % 500 == 0 {
                var prefixes = Set<String>()
                for stored in model.keys {
                    for length in 1...stored.count {
                        prefixes.insert(String(stored.prefix(length)))
                    }
                }
                if trie.nodeCount != prefixes.count { mismatches += 1 }
            }
        }
        #expect(mismatches == 0)
    }
}
