// Generated from src/dsa/content/lessons/swift-types/swift-indirect-enums.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

indirect enum Expr {
    case number(Int)
    case add(Expr, Expr)
    case multiply(Expr, Expr)
    case negate(Expr)
}

func render(_ expression: Expr) -> String {
    switch expression {
    case .number(let value):
        return "\(value)"
    case let .add(left, right):
        return "(\(render(left)) + \(render(right)))"
    case let .multiply(left, right):
        return "(\(render(left)) * \(render(right)))"
    case .negate(let inner):
        return "-\(render(inner))"
    }
}

let tree = Expr.multiply(.negate(.add(.number(1), .number(2))), .number(5))
print(render(tree))
