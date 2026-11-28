import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct HorspoolRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct HorspoolSkipSearchTests {
    /// Every match position, trying every alignment
    private func naivePositions(_ pattern: [UInt8], _ text: [UInt8]) -> [Int] {
        guard !pattern.isEmpty, pattern.count <= text.count else { return [] }
        return (0...(text.count - pattern.count)).filter { s in
            pattern.indices.allSatisfy { pattern[$0] == text[s + $0] }
        }
    }

    /// The alignments the statement's rule visits: only the skips, no comparisons needed
    private func ruleAlignments(_ pattern: [UInt8], _ text: [UInt8]) -> Int {
        let m = pattern.count
        guard m > 0, m <= text.count else { return 0 }
        var skip = [Int](repeating: m, count: 256)
        for k in 0..<(m - 1) {
            skip[Int(pattern[k])] = m - 1 - k
        }
        var count = 0
        var s = 0
        while s <= text.count - m {
            count += 1
            s += skip[Int(text[s + m - 1])]
        }
        return count
    }

    @Test("The examples", arguments: [
        ("example", "here is a simple example", [17], 5),
        ("aa", "aaaa", [0, 1, 2], 3),
        ("abra", "abracadabra", [0, 7], 3),
        ("needle", "haystack", [], 1),
        ("xyz", "ab", [], 0),
    ])
    func examples(pattern: String, text: String, positions: [Int], alignments: Int) {
        let result = HorspoolSkipSearch.search(pattern, in: text)
        #expect(result.positions == positions)
        #expect(result.alignments == alignments)
    }

    @Test("Empty pattern, empty text, and a pattern as long as the text")
    func edges() {
        let empty = HorspoolSkipSearch.search("", in: "anything")
        #expect(empty.positions == [] && empty.alignments == 0)
        let nothing = HorspoolSkipSearch.search("a", in: "")
        #expect(nothing.positions == [] && nothing.alignments == 0)
        let whole = HorspoolSkipSearch.search("swift", in: "swift")
        #expect(whole.positions == [0] && whole.alignments == 1)
        let single = HorspoolSkipSearch.search("s", in: "mississippi")
        #expect(single.positions == [2, 3, 5, 6] && single.alignments == 11)
        let spaces = HorspoolSkipSearch.search("a b", in: "a b a b")
        #expect(spaces.positions == [0, 4])
    }

    @Test("Random texts over small alphabets match trying every position")
    func randomTexts() {
        var random = HorspoolRandom(seed: 63)
        for trial in 0..<300 {
            let alphabet = Array("abcd".utf8).prefix(trial % 3 + 2)
            let text = (0..<Int.random(in: 0...60, using: &random)).map { _ in alphabet.randomElement(using: &random)! }
            let pattern = (0..<Int.random(in: 1...5, using: &random)).map { _ in alphabet.randomElement(using: &random)! }
            let result = HorspoolSkipSearch.search(String(decoding: pattern, as: UTF8.self), in: String(decoding: text, as: UTF8.self))
            #expect(result.positions == naivePositions(pattern, text), "pattern \(pattern), text \(text)")
            #expect(result.alignments == ruleAlignments(pattern, text), "pattern \(pattern), text \(text)")
            if result.positions != naivePositions(pattern, text) || result.alignments != ruleAlignments(pattern, text) { return }
        }
    }

    @Test("Long patterns skip most of a large English-like text")
    func largeEnglish() {
        let line = "the quick brown fox jumps over the lazy dog "
        let text = String(repeating: line, count: 5_000)
        let bytes = Array(text.utf8)
        for pattern in ["lazy", "the lazy brown cat", "lazy dog the quick", "a fox that jumps over cats"] {
            let p = Array(pattern.utf8)
            let result = HorspoolSkipSearch.search(pattern, in: text)
            let expected = naivePositions(p, bytes)
            #expect(result.positions == expected, "positions of \"\(pattern)\"")
            #expect(result.alignments == ruleAlignments(p, bytes), "alignments for \"\(pattern)\"")
            #expect(result.alignments * 3 < bytes.count - p.count + 1, "\"\(pattern)\" should skip most alignments")
        }
        let long = HorspoolSkipSearch.search("a fox that jumps over cats", in: text)
        #expect(long.alignments * 10 < bytes.count, "a 26-character pattern should check fewer than one alignment in 10")
        #expect(HorspoolSkipSearch.search("lazy dog the quick", in: text).positions.count == 4_999)
    }

    @Test("The worst case: every alignment has to be checked")
    func worstCase() {
        let text = String(repeating: "a", count: 20_000)
        let pattern = "b" + String(repeating: "a", count: 49)
        let result = HorspoolSkipSearch.search(pattern, in: text)
        #expect(result.positions == [])
        #expect(result.alignments == 20_000 - 50 + 1)
    }
}
