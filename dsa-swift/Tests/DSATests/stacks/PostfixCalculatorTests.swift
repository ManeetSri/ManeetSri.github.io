import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct PostfixCalculatorTests {
    @Test("Converts infix to postfix", arguments: [
        ("3 + 4", ["3", "4", "+"]),
        ("3 + 4 * 2", ["3", "4", "2", "*", "+"]),
        ("(3 + 4) * 2", ["3", "4", "+", "2", "*"]),
        ("8 - 3 - 2", ["8", "3", "-", "2", "-"]),
        ("12/(2+4)*3", ["12", "2", "4", "+", "/", "3", "*"]),
        ("3 + 4 * (2 - 1)", ["3", "4", "2", "1", "-", "*", "+"]),
        ("42", ["42"]),
        ("((7))", ["7"]),
    ])
    func converts(infix: String, expected: [String]) {
        #expect(PostfixCalculator.postfix(from: infix) == expected)
    }

    @Test("Evaluates postfix", arguments: [
        (["3", "4", "+"], 7),
        (["5", "1", "2", "+", "4", "*", "+", "3", "-"], 14),
        (["8", "3", "-"], 5),
        (["7", "2", "/"], 3),
        (["-7", "2", "/"], -3),
        (["-4", "-6", "*"], 24),
        (["9"], 9),
    ])
    func evaluates(tokens: [String], expected: Int) {
        #expect(PostfixCalculator.evaluate(postfix: tokens) == expected)
    }

    @Test("Calculates infix expressions", arguments: [
        ("1 + 2 * 3", 7),
        ("(1 + 2) * 3", 9),
        ("10 - 4 - 3", 3),
        ("100 / 10 / 5", 2),
        ("2 * (3 + 4) - 5 / 2", 12),
        ("1 - (2 - (3 - 4))", -2),
        ("0", 0),
        ("  6 *  7 ", 42),
    ])
    func calculates(expression: String, expected: Int) {
        #expect(PostfixCalculator.calculate(expression) == expected)
    }

    @Test("Division truncates towards zero")
    func truncation() {
        #expect(PostfixCalculator.calculate("7 / 2") == 3)
        #expect(PostfixCalculator.calculate("(1 - 8) / 2") == -3)
    }

    @Test("Stays fast on a long expression")
    func large() {
        // 1 + 2 + ... + 20,000, and a deeply nested version of the same kind of sum
        let sum = (1...20_000).map(String.init).joined(separator: " + ")
        #expect(PostfixCalculator.calculate(sum) == 20_000 * 20_001 / 2)
        let nested = String(repeating: "(1 + ", count: 10_000) + "0" + String(repeating: ")", count: 10_000)
        #expect(PostfixCalculator.calculate(nested) == 10_000)
        #expect(PostfixCalculator.postfix(from: sum).count == 39_999)
    }
}
