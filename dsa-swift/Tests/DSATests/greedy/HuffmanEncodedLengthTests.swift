import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct HuffmanRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct HuffmanEncodedLengthTests {
    /// The symbol counts of a text
    private func counts(_ text: String) -> [Int] {
        var table: [Character: Int] = [:]
        for symbol in text {
            table[symbol, default: 0] += 1
        }
        return Array(table.values)
    }

    /// Every code tree can be built by some sequence of merges, and its cost is the sum of the merged
    /// weights, so the cheapest of all merge orders is the best possible code. Exponential.
    private func cheapestOfAllMerges(_ weights: [Int]) -> Int {
        if weights.count <= 1 { return 0 }
        var best = Int.max
        for i in weights.indices {
            for j in weights.indices where j > i {
                var rest = weights
                let merged = rest[i] + rest[j]
                rest.remove(at: j)
                rest.remove(at: i)
                rest.append(merged)
                best = min(best, merged + cheapestOfAllMerges(rest))
            }
        }
        return best
    }

    /// Huffman's merges with a sorted array instead of a heap: O(k²), fine as a second opinion
    private func sortedMerges(_ weights: [Int]) -> Int {
        var forest = weights.sorted()
        var cost = 0
        var front = 0
        while forest.count - front > 1 {
            let merged = forest[front] + forest[front + 1]
            front += 2
            cost += merged
            // Insert the merged weight in order, after the front
            var position = forest.count
            while position > front && forest[position - 1] > merged { position -= 1 }
            forest.insert(merged, at: position)
        }
        return cost
    }

    @Test("Examples and small cases", arguments: [
        ("abracadabra", 23),
        ("aaaa", 4),
        ("", 0),
        ("ab", 2),
        ("aab", 3),
        ("abcd", 8),
        ("aaaaaaaaaabcd", 18),
        ("mississippi", 21),
        ("🙂🙂🙃", 3),
    ] as [(String, Int)])
    func examples(text: String, expected: Int) {
        #expect(HuffmanEncodedLength.encodedBits(text) == expected)
    }

    @Test("Matches the cheapest of all merge orders on 300 small random texts")
    func randomSmall() {
        var random = HuffmanRandom(seed: 50)
        let alphabet = Array("abcdef")
        for _ in 0..<300 {
            let distinct = Int.random(in: 1...6, using: &random)
            let text = String((0..<Int.random(in: 1...30, using: &random)).map { _ in alphabet[Int.random(in: 0..<distinct, using: &random)] })
            let weights = counts(text)
            let expected = weights.count == 1 ? text.count : cheapestOfAllMerges(weights)
            #expect(HuffmanEncodedLength.encodedBits(text) == expected, "text \(text)")
        }
    }

    @Test("200,000 characters")
    func large() {
        var random = HuffmanRandom(seed: 2_026)
        // 256 symbols, 100 of each: a balanced tree, 8 bits per character
        let symbols = (0x4E00..<0x4F00).map { Character(Unicode.Scalar($0)!) }
        let even = String(symbols.flatMap { Array(repeating: $0, count: 100) }.shuffled(using: &random))
        #expect(HuffmanEncodedLength.encodedBits(even) == 8 * 25_600)

        // 2,000 symbols with skewed random counts
        let many = (0x4E00..<(0x4E00 + 2_000)).map { Character(Unicode.Scalar($0)!) }
        var characters: [Character] = []
        while characters.count < 200_000 {
            let index = Int.random(in: 0..<many.count, using: &random) * Int.random(in: 0..<many.count, using: &random) / many.count
            characters.append(many[index])
        }
        let skewed = String(characters)
        #expect(HuffmanEncodedLength.encodedBits(skewed) == sortedMerges(counts(skewed)))

        // One symbol repeated: one bit each
        #expect(HuffmanEncodedLength.encodedBits(String(repeating: "z", count: 200_000)) == 200_000)
    }
}
