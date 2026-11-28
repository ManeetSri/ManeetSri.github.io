import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct BracketStringGeneratorTests {
    /// The Catalan numbers: how many balanced strings there are with n pairs
    private let catalan = [1, 1, 2, 5, 14, 42, 132, 429, 1_430, 4_862, 16_796, 58_786, 208_012]

    private func isBalanced(_ text: String, pairs: Int) -> Bool {
        guard text.count == 2 * pairs else { return false }
        var open = 0
        for character in text {
            switch character {
            case "(": open += 1
            case ")": open -= 1
            default: return false
            }
            if open < 0 { return false }
        }
        return open == 0
    }

    /// Every string of brackets of the right length, filtered: slow, but clearly right
    private func reference(_ pairs: Int) -> [String] {
        (0..<(1 << (2 * pairs))).map { mask in
            String((0..<(2 * pairs)).map { mask & (1 << $0) != 0 ? "(" : ")" })
        }
        .filter { isBalanced($0, pairs: pairs) }
        .sorted()
    }

    @Test("Examples", arguments: [
        (0, [""]),
        (1, ["()"]),
        (2, ["(())", "()()"]),
        (3, ["((()))", "(()())", "(())()", "()(())", "()()()"]),
    ] as [(Int, [String])])
    func examples(pairs: Int, expected: [String]) {
        #expect(BracketStringGenerator.balanced(pairs: pairs).sorted() == expected)
    }

    @Test("Matches brute force up to 7 pairs", arguments: 0...7)
    func matchesBruteForce(pairs: Int) {
        #expect(BracketStringGenerator.balanced(pairs: pairs).sorted() == reference(pairs))
    }

    @Test("The right number of valid, distinct strings up to 12 pairs, where filtering all 2^24 raw strings is too slow", arguments: 8...12)
    func counts(pairs: Int) {
        let result = BracketStringGenerator.balanced(pairs: pairs)
        #expect(result.count == catalan[pairs])
        #expect(Set(result).count == catalan[pairs])
        #expect(result.allSatisfy { isBalanced($0, pairs: pairs) })
    }
}
