import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct PrefixTreeDesignTests {
    typealias PrefixTree = PrefixTreeDesign.PrefixTree

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
        let tree = PrefixTree()
        tree.insert("seat")
        #expect(tree.search("seat") == true)
        #expect(tree.search("sea") == false)
        #expect(tree.startsWith("sea") == true)
        tree.insert("sea")
        #expect(tree.search("sea") == true)
        #expect(tree.startsWith("seats") == false)
    }

    @Test("A new tree finds nothing")
    func empty() {
        let tree = PrefixTree()
        #expect(!tree.search("a"))
        #expect(!tree.startsWith("a"))
    }

    @Test("search needs a whole word; startsWith doesn't", arguments: [
        ("car", true, true), ("cart", true, true), ("cat", true, true), ("dog", true, true),
        ("ca", false, true), ("c", false, true), ("do", false, true),
        ("carts", false, false), ("cab", false, false), ("dogs", false, false), ("x", false, false),
    ])
    func searchVersusPrefix(query: String, isWord: Bool, isPrefix: Bool) {
        let tree = PrefixTree()
        for word in ["cart", "car", "cat", "dog"] {
            tree.insert(word)
        }
        #expect(tree.search(query) == isWord)
        #expect(tree.startsWith(query) == isPrefix)
    }

    @Test("Inserting a word twice changes nothing")
    func duplicates() {
        let tree = PrefixTree()
        tree.insert("moon")
        tree.insert("moon")
        #expect(tree.search("moon"))
        #expect(!tree.search("mo"))
        #expect(tree.startsWith("mo"))
    }

    @Test("Single letters, and words inside words")
    func nested() {
        let tree = PrefixTree()
        for word in ["a", "an", "and", "andes", "b"] {
            tree.insert(word)
        }
        for word in ["a", "an", "and", "andes", "b"] {
            #expect(tree.search(word))
        }
        #expect(!tree.search("ande"))
        #expect(tree.startsWith("ande"))
        #expect(!tree.startsWith("bz"))
        #expect(!tree.search("c"))
    }

    @Test("Two trees don't share words")
    func independentTrees() {
        let first = PrefixTree()
        let second = PrefixTree()
        first.insert("alpha")
        second.insert("beta")
        #expect(first.search("alpha"))
        #expect(!first.search("beta"))
        #expect(!first.startsWith("b"))
        #expect(second.search("beta"))
        #expect(!second.startsWith("a"))
    }

    @Test("50,000 random words and 50,000 queries agree with a set")
    func large() {
        var steps = Steps(seed: 40)
        let letters = Array("abcdef")
        func randomWord() -> String {
            String((0...steps.next(below: 10)).map { _ in letters[steps.next(below: letters.count)] })
        }
        let tree = PrefixTree()
        var words = Set<String>()
        var prefixes = Set<String>()
        for _ in 0..<50_000 {
            let word = randomWord()
            tree.insert(word)
            if words.insert(word).inserted {
                for length in 1...word.count {
                    prefixes.insert(String(word.prefix(length)))
                }
            }
        }
        var wrongSearch = 0
        var wrongPrefix = 0
        for _ in 0..<50_000 {
            let query = randomWord()
            if tree.search(query) != words.contains(query) { wrongSearch += 1 }
            if tree.startsWith(query) != prefixes.contains(query) { wrongPrefix += 1 }
        }
        #expect(wrongSearch == 0)
        #expect(wrongPrefix == 0)
    }
}
