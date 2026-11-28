// Generated from src/dsa/content/lessons/stacks/stack-expressions.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func evaluatePostfix(_ expression: String) -> Int? {
    var values: [Int] = []
    for token in expression.split(separator: " ") {
        if let number = Int(token) {
            values.append(number)
            continue
        }
        guard let right = values.popLast(), let left = values.popLast() else {
            return nil                          // an operator without two operands
        }
        switch token {
        case "+": values.append(left + right)
        case "-": values.append(left - right)
        case "*": values.append(left * right)
        case "/": values.append(left / right)
        default: return nil                     // an unknown token
        }
    }
    return values.count == 1 ? values[0] : nil  // exactly one value must remain
}

print(evaluatePostfix("3 4 +") ?? 0)
print(evaluatePostfix("5 1 2 + 4 * + 3 -") ?? 0)
print(evaluatePostfix("8 2 /") ?? 0, evaluatePostfix("2 8 /") ?? 0)
print(evaluatePostfix("1 +") == nil, evaluatePostfix("1 2") == nil)
