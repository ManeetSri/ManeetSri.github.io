// Generated from src/dsa/content/lessons/swift-types/swift-indirect-enums.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

indirect enum Expr {
    case number(Int)
    case add(Expr, Expr)
    case multiply(Expr, Expr)
}

func countNumbers(in expression: Expr) -> Int {
    switch expression {
    case .number:
        return 1
    case let .add(left, right), let .multiply(left, right):
        return countNumbers(in: left) + countNumbers(in: right)
    }
}

func height(of expression: Expr) -> Int {
    switch expression {
    case .number:
        return 1
    case let .add(left, right), let .multiply(left, right):
        return 1 + max(height(of: left), height(of: right))
    }
}

let tree = Expr.add(.number(2), .multiply(.number(3), .number(4)))
print(countNumbers(in: tree))
print(height(of: tree))
