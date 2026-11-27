// Problem: Evaluate an arithmetic tree (M09 · Indirect enums for recursive data)

public enum ArithmeticTree {
    /// An arithmetic expression stored as a tree.
    public indirect enum Expr {
        case number(Int)
        case add(Expr, Expr)
        case subtract(Expr, Expr)
        case multiply(Expr, Expr)
        case negate(Expr)
    }

    // Write your solution here, then run:
    // swift test --filter ArithmeticTreeTests

    /// The value of the expression.
    public static func evaluate(_ expression: Expr) -> Int {
        return 0
    }

    /// The expression as text: every add, subtract and multiply wrapped in brackets with spaces
    /// around the operator, negate written as "-" followed by its expression, numbers as plain digits.
    public static func render(_ expression: Expr) -> String {
        return ""
    }
}
