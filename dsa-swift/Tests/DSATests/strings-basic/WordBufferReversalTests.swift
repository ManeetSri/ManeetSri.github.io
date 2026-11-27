import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct WordBufferReversalTests {
    /// A tiny deterministic generator, so the random cases are the same every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    private func reversed(_ text: String) -> String {
        var chars = Array(text)
        WordBufferReversal.reverseWords(&chars)
        return String(chars)
    }

    @Test("Reverses the words and tidies the spaces", arguments: [
        ("the sky is blue", "blue is sky the"),
        ("  fast   and  safe ", "safe and fast"),
        ("a b", "b a"),
        ("Swift", "Swift"),
        ("   ", ""),
        ("", ""),
        (" x ", "x"),
        ("Hello, World!", "World! Hello,"),
        ("one two  three   four", "four three two one"),
        ("café au lait", "lait au café"),
    ])
    func examples(text: String, expected: String) {
        #expect(reversed(text) == expected)
    }

    @Test("Matches split, reverse and join on random messy lines")
    func matchesSplit() {
        var steps = Steps(seed: 23)
        let pieces: [Character] = ["a", "b", "c", " ", " ", "!"]
        var mismatches = 0
        for _ in 0..<500 {
            let text = String((0..<steps.next(below: 20)).map { _ in pieces[steps.next(below: pieces.count)] })
            let expected = text.split(separator: " ").reversed().joined(separator: " ")
            if reversed(text) != expected { mismatches += 1 }
        }
        #expect(mismatches == 0)
    }

    @Test("Stays O(n) on a 100,000-character line")
    func large() {
        let words = (0..<13_000).map { "w\($0)" }
        let text = "   " + words.joined(separator: "  ") + "  "
        #expect(reversed(text) == words.reversed().joined(separator: " "))
        #expect(reversed(String(repeating: " ", count: 100_000)) == "")
    }
}
