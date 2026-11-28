import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct InPlaceRunCompressorTests {
    /// A tiny deterministic generator, so the random cases are the same every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    /// Compresses `text` and returns the compressed prefix, or nil if the length returned is impossible.
    private func compressed(_ text: String) -> String? {
        var chars = Array(text)
        let length = InPlaceRunCompressor.compress(&chars)
        guard length >= 0 && length <= chars.count else { return nil }
        return String(chars[0..<length])
    }

    /// The same format built into a new string, as a model.
    private func model(_ text: String) -> String {
        let chars = Array(text)
        var result = ""
        var i = 0
        while i < chars.count {
            var j = i
            while j < chars.count && chars[j] == chars[i] { j += 1 }
            result.append(chars[i])
            if j - i > 1 { result += String(j - i) }
            i = j
        }
        return result
    }

    @Test("Compresses each run", arguments: [
        ("aabcccccc", "a2bc6"),
        ("abba", "ab2a"),
        ("xyz", "xyz"),
        (String(repeating: "q", count: 12), "q12"),
        (String(repeating: "m", count: 10) + "nn", "m10n2"),
        ("", ""),
        ("z", "z"),
        ("zz", "z2"),
        ("aaAA", "a2A2"),
        ("!!??!", "!2?2!"),
    ])
    func examples(text: String, expected: String) {
        #expect(compressed(text) == expected)
    }

    @Test("Writes every digit of long counts", arguments: [99, 100, 1_000, 54_321])
    func longRuns(length: Int) {
        #expect(compressed(String(repeating: "b", count: length) + "c") == "b\(length)c")
    }

    @Test("Matches building the result in a new string")
    func matchesModel() {
        var steps = Steps(seed: 230)
        var mismatches = 0
        for _ in 0..<500 {
            var text = ""
            for _ in 0..<steps.next(below: 8) {
                let letter: Character = ["a", "b", "c"][steps.next(below: 3)]
                text += String(repeating: letter, count: 1 + steps.next(below: 14))
            }
            if compressed(text) != model(text) { mismatches += 1 }
        }
        #expect(mismatches == 0)
    }

    @Test("Stays O(n) on 100,000 characters")
    func large() {
        var text = ""
        for index in 0..<10_000 {
            text += String(repeating: index.isMultiple(of: 2) ? "x" : "y", count: 1 + index % 19)
        }
        #expect(compressed(text) == model(text))
        let alternating = String((0..<100_000).map { $0.isMultiple(of: 2) ? Character("u") : Character("v") })
        #expect(compressed(alternating) == alternating)
    }
}
