import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct TallyRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct ShardedWordTallyTests {
    /// The obvious sequential count, to compare against
    private func sequentialCounts(_ documents: [String]) -> [String: Int] {
        var counts: [String: Int] = [:]
        for document in documents {
            for word in document.split(whereSeparator: { !$0.isLetter }) {
                counts[word.lowercased(), default: 0] += 1
            }
        }
        return counts
    }

    @Test("The examples")
    func examples() async {
        let documents = ["The cat sat.", "the CAT ran", "A dog; a cat!"]
        let counts = await ShardedWordTally.counts(in: documents)
        #expect(counts == ["the": 2, "cat": 3, "sat": 1, "ran": 1, "a": 2, "dog": 1])
        #expect(await ShardedWordTally.topWords(in: documents, count: 3) == ["cat", "a", "the"])
        #expect(await ShardedWordTally.topWords(in: documents, count: 10) == ["cat", "a", "the", "dog", "ran", "sat"])
    }

    @Test("No documents, empty documents and documents without letters")
    func empty() async {
        #expect(await ShardedWordTally.counts(in: []).isEmpty)
        #expect(await ShardedWordTally.counts(in: ["", "  ", "123 ... 456"]).isEmpty)
        #expect(await ShardedWordTally.topWords(in: [], count: 3).isEmpty)
        #expect(await ShardedWordTally.topWords(in: ["one two"], count: 0).isEmpty)
    }

    @Test("Words split on digits, punctuation and line breaks")
    func separators() async {
        let counts = await ShardedWordTally.counts(in: ["well-known\nfacts", "it's 2pm", "Café CAFÉ café"])
        #expect(counts == ["well": 1, "known": 1, "facts": 1, "it": 1, "s": 1, "pm": 1, "café": 3])
    }

    @Test("Matches a sequential count on 200 documents")
    func manyDocuments() async {
        var random = TallyRandom(seed: 70)
        let vocabulary = ["swift", "actor", "task", "group", "await", "Sendable", "merge", "sort", "queue", "level"]
        let documents = (0..<200).map { _ in
            (0..<Int.random(in: 0...300, using: &random)).map { _ in
                vocabulary[Int.random(in: 0..<vocabulary.count, using: &random)]
            }.joined(separator: Bool.random(using: &random) ? " " : ", ")
        }
        let expected = sequentialCounts(documents)
        #expect(await ShardedWordTally.counts(in: documents) == expected)
        let top = expected.sorted { ($1.value, $0.key) < ($0.value, $1.key) }.prefix(4).map(\.key)
        #expect(await ShardedWordTally.topWords(in: documents, count: 4) == top)
    }

    @Test("Ties are broken alphabetically")
    func ties() async {
        let documents = ["pear apple", "fig pear", "apple fig", "kiwi"]
        #expect(await ShardedWordTally.topWords(in: documents, count: 4) == ["apple", "fig", "pear", "kiwi"])
    }
}
