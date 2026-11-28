import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct EveryPatternMatchTests {
    /// A tiny deterministic generator, so the random tests do the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    /// Try every start and compare: slow on bad inputs, but obviously right.
    private static func naive(_ pattern: String, _ text: String) -> [Int] {
        let p = Array(pattern.utf8), t = Array(text.utf8)
        guard !p.isEmpty, p.count <= t.count else { return [] }
        return (0...(t.count - p.count)).filter { t[$0..<($0 + p.count)].elementsEqual(p) }
    }

    private static func randomText(_ length: Int, from letters: [Character], _ steps: inout Steps) -> String {
        String((0..<length).map { _ in letters[steps.next(below: letters.count)] })
    }

    @Test("Examples and edge cases", arguments: [
        ("abra", "abracadabra", [0, 7]),
        ("aa", "aaaa", [0, 1, 2]),
        ("ana", "bananas", [1, 3]),
        ("xyz", "abc", []),
        ("longer", "short", []),
        ("a", "", []),
        ("abc", "abc", [0]),
        ("abacabab", "abacabacabab", [4]),
        ("needle", "a needle, then another needle", [2, 23]),
        ("A b", "A bA b", [0, 3]),
    ] as [(String, String, [Int])])
    func examples(pattern: String, text: String, expected: [Int]) {
        #expect(EveryPatternMatch.positions(of: pattern, in: text) == expected)
    }

    @Test("Matches naive search on 2,000 random small cases")
    func randomSmall() {
        var steps = Steps(seed: 63)
        for round in 0..<2_000 {
            let letters: [Character] = round % 2 == 0 ? ["a", "b"] : ["a", "b", "c"]
            let text = Self.randomText(steps.next(below: 30), from: letters, &steps)
            let pattern = Self.randomText(1 + steps.next(below: 5), from: letters, &steps)
            #expect(EveryPatternMatch.positions(of: pattern, in: text) == Self.naive(pattern, text))
        }
    }

    @Test("100,000 a's: the input that makes naive matching quadratic")
    func adversarial() {
        let text = String(repeating: "a", count: 100_000)
        let half = String(repeating: "a", count: 50_000)
        let almost = String(repeating: "a", count: 49_999) + "b"
        #expect(EveryPatternMatch.positions(of: half, in: text) == Array(0...50_000))
        #expect(EveryPatternMatch.positions(of: almost, in: text + "b") == [50_001])
        #expect(EveryPatternMatch.positions(of: almost, in: text).isEmpty)
    }

    @Test("Long periodic and random texts")
    func longTexts() {
        let periodic = String(repeating: "ab", count: 50_000)
        let pattern = String(repeating: "ab", count: 500) + "a"
        #expect(EveryPatternMatch.positions(of: pattern, in: periodic) == Array(stride(from: 0, through: 98_999, by: 2)))

        var steps = Steps(seed: 2_026)
        let text = Self.randomText(100_000, from: ["a", "b"], &steps)
        let bytes = Array(text.utf8)
        for start in [0, 777, 54_321, 99_980] {
            let piece = String(decoding: bytes[start..<(start + 20)], as: UTF8.self)
            #expect(EveryPatternMatch.positions(of: piece, in: text) == Self.naive(piece, text))
        }
    }
}
