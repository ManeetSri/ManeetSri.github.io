import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct BracketCheckTests {
    @Test("Accepts balanced text", arguments: [
        "()",
        "([]{})",
        "{[()()]}",
        "",
        "no brackets at all",
        "if (a[i] > b) { print(a) }",
        "(((())))[]",
    ])
    func balanced(text: String) {
        #expect(BracketCheck.isBalanced(text))
    }

    @Test("Rejects unbalanced text", arguments: [
        "(",
        ")",
        "(]",
        "([)]",
        "(()",
        "())(",
        "}{",
        "let x = [1, 2",
        "{[}]",
    ])
    func unbalanced(text: String) {
        #expect(!BracketCheck.isBalanced(text))
    }

    @Test("Matching counts aren't enough: the order matters")
    func orderMatters() {
        #expect(!BracketCheck.isBalanced("[(])"))
        #expect(BracketCheck.isBalanced("[()]"))
    }

    @Test("Stays fast on 200,000 brackets")
    func large() {
        let deep = String(repeating: "([{", count: 33_333) + String(repeating: "}])", count: 33_333)
        #expect(BracketCheck.isBalanced(deep))
        #expect(!BracketCheck.isBalanced(deep + "("))
        #expect(!BracketCheck.isBalanced(")" + deep))
        let flat = String(repeating: "()[]{}", count: 33_333)
        #expect(BracketCheck.isBalanced(flat))
    }
}
