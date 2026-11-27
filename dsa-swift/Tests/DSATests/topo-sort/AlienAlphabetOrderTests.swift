import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct AlienAlphabetOrderTests {
    /// A tiny deterministic generator, so the large word lists are the same every run.
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

    /// True when `word` comes before `other` (or equals it) under the letter ranks: dictionary order.
    private func inOrder(_ word: [Character], _ other: [Character], _ rank: [Character: Int]) -> Bool {
        for (a, b) in zip(word, other) where a != b {
            return rank[a]! < rank[b]!
        }
        return word.count <= other.count
    }

    /// Many alphabets can be right, so the tests check the answer's properties instead of comparing
    /// it with one string: it holds exactly the letters used, each once, and under it the words are
    /// in dictionary order.
    private func isValid(_ alphabet: String, for words: [String]) -> Bool {
        let used = Set(words.flatMap { $0 })
        guard alphabet.count == used.count, Set(alphabet) == used else { return false }
        let rank = Dictionary(uniqueKeysWithValues: alphabet.enumerated().map { ($1, $0) })
        let arrays = words.map { Array($0) }
        return zip(arrays, arrays.dropFirst()).allSatisfy { inOrder($0, $1, rank) }
    }

    @Test("Word lists with an alphabet", arguments: [
        ["bdc", "bda", "cb", "cab", "ad"],          // b before c before a; d can go anywhere
        ["toe", "tea", "eat", "ate"],
        ["kite"],                                   // no information: any order of k, i, t, e
        ["moon", "moon", "mop"],                    // equal neighbours are fine
        ["ab", "abc", "b"],                         // a prefix first is fine
        ["z", "zx", "x"],                           // z before x, learnt from the last pair
        ["cc", "cb", "ca", "bc", "ba", "aa"],
        ["q"],
        ["ba", "bc", "ac", "cab"],
    ])
    func valid(words: [String]) {
        let alphabet = AlienAlphabetOrder.alphabet(words)
        #expect(isValid(alphabet, for: words), "got \"\(alphabet)\"")
    }

    @Test("Exactly one alphabet fits")
    func unique() {
        #expect(AlienAlphabetOrder.alphabet(["xy", "xz", "yx", "yz", "z"]) == "xyz")
        #expect(AlienAlphabetOrder.alphabet(["c", "b", "a"]) == "cba")
    }

    @Test("Contradictions give \"\"", arguments: [
        ["ba", "ab", "bb"],                         // b before a, then a before b
        ["x", "y", "x"],
        ["ab", "bc", "ca", "ad"],                   // a before b before c before a
    ])
    func contradictions(words: [String]) {
        #expect(AlienAlphabetOrder.alphabet(words) == "")
    }

    @Test("A word before its own prefix gives \"\"", arguments: [
        ["apple", "app"],
        ["ab", "a"],
        ["c", "deer", "dee"],
    ])
    func prefixes(words: [String]) {
        #expect(AlienAlphabetOrder.alphabet(words) == "")
    }

    @Test("Letters that only appear after the first difference still count")
    func unconstrained() {
        let words = ["mq", "nz", "nzx"]             // m before n; q, z and x are free
        let alphabet = AlienAlphabetOrder.alphabet(words)
        #expect(alphabet.count == 5)
        #expect(isValid(alphabet, for: words), "got \"\(alphabet)\"")
    }

    @Test("20,000 words sorted under a scrambled alphabet")
    func large() {
        var steps = Steps(seed: 2_024)
        var secret = Array("abcdefghijklmnopqrstuvwxyz")
        for index in stride(from: 25, to: 0, by: -1) {
            secret.swapAt(index, steps.next(below: index + 1))
        }
        let rank = Dictionary(uniqueKeysWithValues: secret.enumerated().map { ($1, $0) })
        var lists = (0..<20_000).map { _ in
            (0..<(1 + steps.next(below: 8))).map { _ in secret[steps.next(below: 26)] }
        }
        lists.sort { a, b in
            for (x, y) in zip(a, b) where x != y { return rank[x]! < rank[y]! }
            return a.count < b.count
        }
        var words = lists.map { String($0) }
        let alphabet = AlienAlphabetOrder.alphabet(words)
        #expect(isValid(alphabet, for: words))

        // Add a longer word and then its own prefix at the end: no alphabet fits any more
        let last = words[words.count - 1]
        words.append(last + last)
        words.append(last)
        #expect(AlienAlphabetOrder.alphabet(words) == "")
    }
}
