import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct CutRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct PalindromeCutPlansTests {
    /// Writes each plan as "a|bb|a" and sorts them, so answers in any order compare equal
    private func canonical(_ plans: [[String]]) -> [String] {
        plans.map { $0.joined(separator: "|") }.sorted()
    }

    private func isPalindrome(_ piece: String) -> Bool {
        !piece.isEmpty && piece == String(piece.reversed())
    }

    /// Every set of cut positions, kept if all its pieces are palindromes: slow, but clearly right
    private func reference(_ text: String) -> [String] {
        let letters = Array(text)
        var plans: [[String]] = []
        for mask in 0..<(1 << (letters.count - 1)) {
            var pieces: [String] = []
            var start = 0
            for gap in 0..<letters.count where gap == letters.count - 1 || mask & (1 << gap) != 0 {
                pieces.append(String(letters[start...gap]))
                start = gap + 1
            }
            if pieces.allSatisfy(isPalindrome) { plans.append(pieces) }
        }
        return canonical(plans)
    }

    @Test("Examples and small cases", arguments: [
        ("noon", ["n|o|o|n", "n|oo|n", "noon"]),
        ("eye", ["e|y|e", "eye"]),
        ("abc", ["a|b|c"]),
        ("x", ["x"]),
        ("abba", ["a|b|b|a", "a|bb|a", "abba"]),
        ("aab", ["a|a|b", "aa|b"]),
    ] as [(String, [String])])
    func examples(text: String, expected: [String]) {
        #expect(canonical(PalindromeCutPlans.plans(text)) == expected.sorted())
    }

    @Test("Matches brute force on 300 random strings")
    func randomSmall() {
        var random = CutRandom(seed: 48)
        let alphabet = Array("abc")
        for _ in 0..<300 {
            let text = String((0..<Int.random(in: 1...12, using: &random)).map { _ in
                alphabet[Int.random(in: 0..<Int.random(in: 1...3, using: &random), using: &random)]
            })
            #expect(canonical(PalindromeCutPlans.plans(text)) == reference(text), "text \(text)")
        }
    }

    @Test("24 different letters: one plan, though there are 2^23 ways to cut")
    func noLongPalindromes() {
        let text = "qwertyuiopasdfghjklzxcvb"
        #expect(canonical(PalindromeCutPlans.plans(text)) == [text.map { String($0) }.joined(separator: "|")])
    }

    @Test("A palindrome with many inner palindromes matches brute force")
    func nested() {
        let text = "abacabadabacaba"
        #expect(canonical(PalindromeCutPlans.plans(text)) == reference(text))
    }

    @Test("Sixteen equal letters: every one of the 32,768 cut plans works")
    func allEqual() {
        let text = String(repeating: "m", count: 16)
        let result = PalindromeCutPlans.plans(text)
        #expect(result.count == 32_768)
        #expect(Set(canonical(result)).count == 32_768)
        #expect(result.allSatisfy { $0.joined() == text })
    }
}
