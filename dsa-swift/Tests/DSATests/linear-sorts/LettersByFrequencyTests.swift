import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct LettersByFrequencyTests {
    /// A tiny deterministic generator, so the randomised tests do the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    /// The expected answer, worked out the slow, obvious way: sort the letters by (count, letter).
    private static func expected(_ text: String) -> String {
        var counts: [Character: Int] = [:]
        for letter in text { counts[letter, default: 0] += 1 }
        let order = counts.keys.sorted { (counts[$1]!, $0) < (counts[$0]!, $1) }
        return order.map { String(repeating: $0, count: counts[$0]!) }.joined()
    }

    @Test("Arranges the examples", arguments: [
        ("banana", "aaannb"),
        ("letter", "eettlr"),
        ("zzyx", "zzxy"),
        ("abc", "abc"),
        ("cba", "abc"),
        ("mississippi", "iiiissssppm"),
        ("q", "q"),
        ("", ""),
    ])
    func examples(text: String, expected: String) {
        #expect(LettersByFrequency.arrange(text) == expected)
    }

    @Test("Matches a slow, obvious answer on hundreds of random strings")
    func randomised() {
        var steps = Steps(seed: 26)
        var firstFailure: String? = nil
        for round in 0..<300 {
            let alphabet = 1 + round % 26
            let text = String((0..<steps.next(below: 40)).map { _ in
                Character(UnicodeScalar(UInt8(97 + steps.next(below: alphabet))))
            })
            if LettersByFrequency.arrange(text) != Self.expected(text) {
                firstFailure = firstFailure ?? text
            }
        }
        #expect(firstFailure == nil, "the first string arranged wrongly")
    }

    @Test("Stays fast on 200,000 letters")
    func large() {
        var steps = Steps(seed: 200)
        // Letter i appears roughly in proportion to i + 1, so the counts are all different-ish
        let bytes: [UInt8] = (0..<200_000).map { _ in
            let pick = steps.next(below: 351)            // 351 = 1 + 2 + … + 26
            var letter = 0
            var total = 1
            while total <= pick {
                letter += 1
                total += letter + 1
            }
            return UInt8(97 + letter)
        }
        let text = String(decoding: bytes, as: UTF8.self)
        #expect(LettersByFrequency.arrange(text) == Self.expected(text))
    }

    @Test("All the same letter, and every letter once")
    func extremes() {
        let same = String(repeating: "k", count: 100_000)
        #expect(LettersByFrequency.arrange(same) == same)
        #expect(LettersByFrequency.arrange("zyxwvutsrqponmlkjihgfedcba") == "abcdefghijklmnopqrstuvwxyz")
    }
}
