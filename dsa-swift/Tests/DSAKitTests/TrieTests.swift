import Testing
import DSAKit

@Suite struct TrieTests {
    /// A tiny deterministic generator, so the mixed-operation tests do the same thing every run.
    private struct Steps {
        private var state: UInt64

        init(seed: UInt64) {
            state = seed
        }

        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    @Test("A new trie is empty")
    func startsEmpty() {
        var trie = Trie()
        #expect(trie.isEmpty)
        #expect(trie.count == 0)
        #expect(trie.nodeCount == 0)
        #expect(!trie.contains(""))
        #expect(!trie.contains("a"))
        #expect(!trie.hasPrefix(""))
        #expect(trie.count(withPrefix: "") == 0)
        #expect(trie.words(withPrefix: "") == [])
        #expect(trie.remove("a") == false)
        #expect(Array(trie) == [])
        #expect(trie.description == "Trie([])")
    }

    @Test("Insert, contains and hasPrefix")
    func basics() {
        var trie = Trie()
        #expect(trie.insert("cart") == true)
        #expect(trie.insert("car") == true)
        #expect(trie.insert("dog") == true)
        #expect(trie.count == 3)
        #expect(trie.contains("car"))
        #expect(trie.contains("cart"))
        #expect(!trie.contains("ca"))
        #expect(!trie.contains("cars"))
        #expect(!trie.contains("do"))
        #expect(trie.hasPrefix("ca"))
        #expect(trie.hasPrefix("car"))
        #expect(trie.hasPrefix("cart"))
        #expect(trie.hasPrefix("d"))
        #expect(!trie.hasPrefix("carts"))
        #expect(!trie.hasPrefix("x"))
        // c-a-r-t and d-o-g: "car" adds no nodes of its own
        #expect(trie.nodeCount == 7)
    }

    @Test("Duplicates are stored once")
    func duplicates() {
        var trie: Trie = ["apple", "apple", "app"]
        #expect(trie.count == 2)
        #expect(trie.insert("apple") == false)
        #expect(trie.insert("app") == false)
        #expect(trie.count == 2)
        #expect(trie.nodeCount == 5)
        #expect(trie.count(withPrefix: "ap") == 2)
        #expect(trie.remove("apple") == true)
        #expect(trie.remove("apple") == false)
        #expect(trie.contains("app"))
        #expect(trie.count == 1)
    }

    @Test("The empty string is a word like any other")
    func emptyString() {
        var trie = Trie()
        #expect(trie.insert("") == true)
        #expect(trie.insert("") == false)
        #expect(trie.count == 1)
        #expect(!trie.isEmpty)
        #expect(trie.nodeCount == 0)
        #expect(trie.contains(""))
        #expect(trie.hasPrefix(""))
        #expect(!trie.hasPrefix("a"))
        trie.insert("a")
        #expect(trie.words(withPrefix: "") == ["", "a"])
        #expect(Array(trie) == ["", "a"])
        #expect(trie.count(withPrefix: "") == 2)
        #expect(trie.remove("") == true)
        #expect(!trie.contains(""))
        #expect(trie.contains("a"))
        #expect(trie.count == 1)
        #expect(trie.nodeCount == 1)
        #expect(trie.remove("") == false)
    }

    @Test("Prefixes that are words themselves")
    func prefixesThatAreWords() {
        var trie: Trie = ["a", "an", "and", "ant", "anthem"]
        #expect(trie.count(withPrefix: "a") == 5)
        #expect(trie.count(withPrefix: "an") == 4)
        #expect(trie.count(withPrefix: "ant") == 2)
        #expect(trie.count(withPrefix: "anth") == 1)
        #expect(trie.count(withPrefix: "anthems") == 0)
        #expect(trie.words(withPrefix: "an") == ["an", "and", "ant", "anthem"])
        #expect(trie.words(withPrefix: "ant") == ["ant", "anthem"])
        #expect(trie.words(withPrefix: "b") == [])
        // Removing a word that is a prefix of others keeps every node
        let before = trie.nodeCount
        #expect(trie.remove("an") == true)
        #expect(trie.nodeCount == before)
        #expect(!trie.contains("an"))
        #expect(trie.hasPrefix("an"))
        #expect(trie.count(withPrefix: "an") == 3)
        #expect(trie.words(withPrefix: "a") == ["a", "and", "ant", "anthem"])
    }

    @Test("Removal prunes branches that no other word uses")
    func pruning() {
        var trie: Trie = ["car", "cart", "cat", "dog"]
        #expect(trie.nodeCount == 8)                   // c, a, r, t, t, d, o, g
        #expect(trie.remove("cart") == true)
        #expect(trie.nodeCount == 7)                   // the "t" after "car" is gone
        #expect(!trie.hasPrefix("cart"))
        #expect(trie.remove("dog") == true)
        #expect(trie.nodeCount == 4)                   // d, o, g all gone
        #expect(!trie.hasPrefix("d"))
        #expect(trie.remove("ca") == false)            // a prefix, not a word: nothing changes
        #expect(trie.nodeCount == 4)
        #expect(trie.remove("car") == true)
        #expect(trie.nodeCount == 3)                   // c, a, t
        #expect(trie.remove("cat") == true)
        #expect(trie.nodeCount == 0)
        #expect(trie.isEmpty)
        #expect(!trie.hasPrefix(""))
        // Everything can be added back
        trie.insert("cab")
        #expect(trie.nodeCount == 3)
        #expect(Array(trie) == ["cab"])
    }

    @Test("Node count equals the number of distinct non-empty prefixes")
    func nodeCountMatchesPrefixes() {
        let words = ["tea", "ten", "to", "inn", "in", "i", "a"]
        let trie = Trie(words)
        var prefixes = Set<String>()
        for word in words {
            for length in 1...word.count {
                prefixes.insert(String(word.prefix(length)))
            }
        }
        #expect(trie.nodeCount == prefixes.count)
        #expect(trie.nodeCount == 9)
    }

    @Test("Words come out in sorted order")
    func sortedOrder() {
        let words = ["banana", "apple", "band", "ban", "apricot", "b", "zebra", "Apple"]
        let trie = Trie(words)
        #expect(Array(trie) == words.sorted())
        #expect(trie.words(withPrefix: "ban") == ["ban", "banana", "band"])
        #expect(trie.words(withPrefix: "") == words.sorted())
        #expect(trie.description == "Trie(\(words.sorted()))")
        #expect(trie.map { $0.count } == words.sorted().map { $0.count })
    }

    @Test("A limit returns the first words in order and stops early")
    func limit() {
        let trie: Trie = ["car", "card", "care", "careful", "cart", "cat", "dog"]
        #expect(trie.words(withPrefix: "ca", limit: 3) == ["car", "card", "care"])
        #expect(trie.words(withPrefix: "car", limit: 1) == ["car"])
        #expect(trie.words(withPrefix: "care", limit: 10) == ["care", "careful"])
        #expect(trie.words(withPrefix: "", limit: 0) == [])
        #expect(trie.words(withPrefix: "x", limit: 5) == [])
        #expect(trie.words(withPrefix: "", limit: 100) == Array(trie))
    }

    @Test("Unicode words: accents, canonical equivalence and emoji")
    func unicode() {
        var trie: Trie = ["café", "cafe", "naïve", "🍎pie", "🍎", "日本語"]
        #expect(trie.count == 6)
        #expect(trie.contains("café"))
        #expect(trie.contains("cafe"))
        #expect(!trie.contains("caf"))
        #expect(trie.count(withPrefix: "caf") == 2)
        // "e" plus a combining acute accent is the same Character as the precomposed "é"
        #expect(trie.contains("cafe\u{301}"))
        #expect(trie.insert("cafe\u{301}") == false)
        #expect(trie.count(withPrefix: "🍎") == 2)
        #expect(trie.words(withPrefix: "🍎") == ["🍎", "🍎pie"])
        #expect(trie.hasPrefix("日本"))
        #expect(trie.words(withPrefix: "日") == ["日本語"])
        // An emoji with a skin tone is one Character, distinct from the plain emoji
        trie.insert("👍🏽")
        #expect(!trie.contains("👍"))
        #expect(!trie.hasPrefix("👍"))
        #expect(trie.contains("👍🏽"))
        #expect(trie.remove("café") == true)
        #expect(!trie.contains("cafe\u{301}"))
        #expect(trie.contains("cafe"))
        // One node per Character, not per byte or scalar
        #expect(Trie(["👍🏽👍🏽"]).nodeCount == 2)
    }

    @Test("Copies are independent")
    func valueSemantics() {
        var original: Trie = ["one", "two"]
        var copy = original
        copy.insert("three")
        copy.remove("one")
        #expect(Array(original) == ["one", "two"])
        #expect(Array(copy) == ["three", "two"])
        #expect(original.nodeCount == 6)
        original.remove("two")
        #expect(Array(original) == ["one"])
        #expect(Array(copy) == ["three", "two"])
        #expect(original != copy)
        #expect(Trie(["b", "a"]) == ["a", "b"])
    }

    @Test("Changing a trie while iterating over it doesn't disturb the iteration")
    func mutateWhileIterating() {
        var trie: Trie = ["a", "b", "c"]
        var seen: [String] = []
        for word in trie {
            seen.append(word)
            trie.insert(word + word)
            trie.remove("c")
        }
        #expect(seen == ["a", "b", "c"])
        #expect(Array(trie) == ["a", "aa", "b", "bb", "cc"])
    }

    @Test("removeAll empties the trie")
    func removeAll() {
        var trie: Trie = ["x", "xy"]
        let copy = trie
        trie.removeAll()
        #expect(trie.isEmpty)
        #expect(trie.nodeCount == 0)
        #expect(copy.count == 2)
    }

    @Test("A very long word doesn't overflow the stack")
    func longWord() {
        let long = String(repeating: "ab", count: 100_000)
        var trie: Trie = [long, "abc"]
        #expect(trie.nodeCount == 200_001)
        #expect(trie.contains(long))
        #expect(trie.count(withPrefix: "ab") == 2)
        let copy = trie
        #expect(trie.remove(long) == true)
        #expect(trie.nodeCount == 3)
        #expect(copy.contains(long))
    }

    @Test("Thousands of random operations agree with a Set model")
    func randomOperations() {
        var steps = Steps(seed: 40)
        var trie = Trie()
        var model = Set<String>()
        let letters = Array("abc")
        var mismatches = 0
        func randomWord() -> String {
            String((0..<steps.next(below: 6)).map { _ in letters[steps.next(below: letters.count)] })
        }
        for step in 0..<20_000 {
            let word = randomWord()
            switch steps.next(below: 5) {
            case 0, 1:
                if trie.insert(word) != model.insert(word).inserted { mismatches += 1 }
            case 2:
                if trie.remove(word) != (model.remove(word) != nil) { mismatches += 1 }
            case 3:
                if trie.contains(word) != model.contains(word) { mismatches += 1 }
                let expected = model.filter { $0.hasPrefix(word) }.count
                if trie.count(withPrefix: word) != expected { mismatches += 1 }
                if trie.hasPrefix(word) != (expected > 0) { mismatches += 1 }
            default:
                if trie.words(withPrefix: word) != model.filter({ $0.hasPrefix(word) }).sorted() { mismatches += 1 }
            }
            if trie.count != model.count { mismatches += 1 }
            if step % 1_000 == 0 {
                if Array(trie) != model.sorted() { mismatches += 1 }
                // Pruning keeps exactly one node per distinct non-empty prefix of a stored word
                var prefixes = Set<String>()
                for stored in model where !stored.isEmpty {
                    for length in 1...stored.count {
                        prefixes.insert(String(stored.prefix(length)))
                    }
                }
                if trie.nodeCount != prefixes.count { mismatches += 1 }
            }
        }
        #expect(mismatches == 0)
        #expect(Array(trie) == model.sorted())
    }

    @Test("Thousands of longer random words, inserted and then removed")
    func manyWords() {
        var steps = Steps(seed: 7)
        var words: [String] = []
        for _ in 0..<5_000 {
            let length = 1 + steps.next(below: 12)
            words.append(String((0..<length).map { _ in Character(UnicodeScalar(UInt8(97 + steps.next(below: 26)))) }))
        }
        var trie = Trie(words)
        let distinct = Set(words)
        #expect(trie.count == distinct.count)
        #expect(Array(trie) == distinct.sorted())
        for word in words.prefix(2_500) {
            trie.remove(word)
        }
        let remaining = distinct.subtracting(words.prefix(2_500))
        #expect(trie.count == remaining.count)
        #expect(Array(trie) == remaining.sorted())
        for word in words {
            trie.remove(word)
        }
        #expect(trie.isEmpty)
        #expect(trie.nodeCount == 0)
    }
}
