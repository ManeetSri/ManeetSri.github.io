import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ArithmeticTreeTests {
    typealias Expr = ArithmeticTree.Expr

    @Test("A number is its own value")
    func numbers() {
        #expect(ArithmeticTree.evaluate(.number(7)) == 7)
        #expect(ArithmeticTree.evaluate(.number(-4)) == -4)
        #expect(ArithmeticTree.evaluate(.number(0)) == 0)
    }

    @Test("The tree's shape decides what happens first")
    func shapeDecidesOrder() {
        #expect(ArithmeticTree.evaluate(.add(.number(2), .multiply(.number(3), .number(4)))) == 14)
        #expect(ArithmeticTree.evaluate(.multiply(.add(.number(2), .number(3)), .number(4))) == 20)
    }

    @Test("Subtraction keeps left and right in order")
    func subtraction() {
        #expect(ArithmeticTree.evaluate(.subtract(.number(10), .subtract(.number(4), .number(1)))) == 7)
        #expect(ArithmeticTree.evaluate(.subtract(.subtract(.number(10), .number(4)), .number(1))) == 5)
        #expect(ArithmeticTree.evaluate(.subtract(.number(3), .number(8))) == -5)
    }

    @Test("Negation")
    func negation() {
        #expect(ArithmeticTree.evaluate(.negate(.add(.number(1), .number(2)))) == -3)
        #expect(ArithmeticTree.evaluate(.negate(.negate(.number(5)))) == 5)
        #expect(ArithmeticTree.evaluate(.multiply(.negate(.number(2)), .negate(.number(6)))) == 12)
    }

    @Test("Rendering", arguments: [
        (Expr.number(7), "7"),
        (Expr.number(-3), "-3"),
        (Expr.add(.number(2), .multiply(.number(3), .number(4))), "(2 + (3 * 4))"),
        (Expr.multiply(.add(.number(2), .number(3)), .number(4)), "((2 + 3) * 4)"),
        (Expr.subtract(.number(10), .negate(.number(2))), "(10 - -2)"),
        (Expr.negate(.add(.number(1), .number(2))), "-(1 + 2)"),
        (Expr.negate(.number(5)), "-5"),
    ])
    func rendering(expression: Expr, expected: String) {
        #expect(ArithmeticTree.render(expression) == expected)
    }

    @Test("Handles a deep tree")
    func deepTree() {
        var tree = Expr.number(0)
        for value in 1...1_000 {
            tree = .add(tree, .number(value))
        }
        #expect(ArithmeticTree.evaluate(tree) == 500_500)
    }

    @Test("Renders a tree 100 levels deep")
    func renderDeepTree() {
        var tree = Expr.number(0)
        for value in 1...100 {
            tree = .add(tree, .number(value))
        }
        let text = ArithmeticTree.render(tree)
        #expect(text.hasPrefix(String(repeating: "(", count: 100) + "0 + 1) + 2)"))
        #expect(text.hasSuffix(" + 99) + 100)"))
    }
}
