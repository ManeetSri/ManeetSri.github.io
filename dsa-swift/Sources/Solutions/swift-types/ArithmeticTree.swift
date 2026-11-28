// Reference solution: Evaluate an arithmetic tree. Both functions visit every node once: O(n) time,
// and O(h) space for the recursion, where h is the tree's height.

public enum ArithmeticTree {
    public indirect enum Expr {
        case number(Int)
        case add(Expr, Expr)
        case subtract(Expr, Expr)
        case multiply(Expr, Expr)
        case negate(Expr)
    }

    public static func evaluate(_ expression: Expr) -> Int {
        switch expression {
        case .number(let value):
            return value
        case let .add(left, right):
            return evaluate(left) + evaluate(right)
        case let .subtract(left, right):
            return evaluate(left) - evaluate(right)
        case let .multiply(left, right):
            return evaluate(left) * evaluate(right)
        case .negate(let inner):
            return -evaluate(inner)
        }
    }

    public static func render(_ expression: Expr) -> String {
        switch expression {
        case .number(let value):
            return String(value)
        case let .add(left, right):
            return "(\(render(left)) + \(render(right)))"
        case let .subtract(left, right):
            return "(\(render(left)) - \(render(right)))"
        case let .multiply(left, right):
            return "(\(render(left)) * \(render(right)))"
        case .negate(let inner):
            return "-" + render(inner)
        }
    }
}
