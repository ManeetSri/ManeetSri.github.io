// Generated from src/dsa/content/lessons/swift-types/swift-indirect-enums.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

indirect enum Expr {
    case number(Int)
    case add(Expr, Expr)
    case multiply(Expr, Expr)
}

func evaluate(_ expression: Expr) -> Int {
    switch expression {
    case .number(let value):
        return value
    case let .add(left, right):
        return evaluate(left) + evaluate(right)
    case let .multiply(left, right):
        return evaluate(left) * evaluate(right)
    }
}

let tree = Expr.add(.number(2), .multiply(.number(3), .number(4)))
print(evaluate(tree))
print(evaluate(.multiply(.add(.number(2), .number(3)), .number(4))))
