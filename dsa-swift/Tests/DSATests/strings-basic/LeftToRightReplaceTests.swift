import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct LeftToRightReplaceTests {
    /// A tiny deterministic generator, so the random cases are the same every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    private func randomText(_ steps: inout Steps, maxLength: Int) -> String {
        String((0..<steps.next(below: maxLength + 1)).map { _ in steps.next(below: 3) == 0 ? Character("b") : Character("a") })
    }

    @Test("Replaces matches left to right", arguments: [
        ("cat", "dog", "cat scatter", "dog sdogter"),
        ("aa", "b", "aaaaa", "bba"),
        ("aba", "X", "abababa", "XbX"),
        ("o", "oo", "foo", "foooo"),
        ("xyz", "!", "abc", "abc"),
        ("", "-", "abc", "abc"),
        ("longer", "?", "short", "short"),
        ("abc", "", "abcabcab", "ab"),
        ("ab", "ba", "aabb", "abab"),
        ("x", "y", "", ""),
        ("swift", "Swift", "swift or Swift", "Swift or Swift"),
        ("é", "e", "café crème", "cafe crème"),
        ("same", "same", "same", "same"),
    ])
    func examples(pattern: String, replacement: String, text: String, expected: String) {
        #expect(LeftToRightReplace.replacingAll(pattern, with: replacement, in: text) == expected)
    }

    @Test("Matches the standard library on random texts")
    func matchesLibrary() {
        var steps = Steps(seed: 2_315)
        var mismatches = 0
        for _ in 0..<500 {
            let text = randomText(&steps, maxLength: 20)
            var pattern = randomText(&steps, maxLength: 4)
            if pattern.isEmpty { pattern = "a" }
            let replacement = steps.next(below: 2) == 0 ? "" : "<\(pattern)>"
            let expected = String(text.replacing(pattern, with: replacement))
            if LeftToRightReplace.replacingAll(pattern, with: replacement, in: text) != expected { mismatches += 1 }
        }
        #expect(mismatches == 0)
    }

    @Test("Stays fast on 50,000 characters")
    func large() {
        let text = String(repeating: "a", count: 50_000)
        #expect(LeftToRightReplace.replacingAll("aa", with: "b", in: text) == String(repeating: "b", count: 25_000))
        let nearMiss = String(repeating: "a", count: 49) + "b"       // almost matches at every start
        #expect(LeftToRightReplace.replacingAll(nearMiss, with: "!", in: text) == text)
        #expect(LeftToRightReplace.replacingAll(nearMiss, with: "!", in: text + "b") == String(repeating: "a", count: 49_951) + "!")
    }
}
