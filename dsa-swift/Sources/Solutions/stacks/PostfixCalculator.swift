// Reference solution: A postfix calculator. postfix(from:) is the shunting-yard algorithm: numbers go
// straight to the output, operators wait on a stack until an operator of lower precedence (or a
// closing parenthesis, or the end) forces them out. evaluate(postfix:) pushes numbers and lets each
// operator combine the top two. Both are O(n) time and space for n characters or tokens.

public enum PostfixCalculator {
    private static let precedence: [String: Int] = ["+": 1, "-": 1, "*": 2, "/": 2]

    public static func postfix(from infix: String) -> [String] {
        var output: [String] = []
        var operators: [String] = []
        var number = ""

        func flushNumber() {
            if !number.isEmpty {
                output.append(number)
                number = ""
            }
        }

        for character in infix {
            if ("0"..."9").contains(character) {
                number.append(character)
                continue
            }
            flushNumber()
            let token = String(character)
            if let rank = precedence[token] {
                // Left-associative: pop operators of higher or equal precedence first
                while let top = operators.last, let topRank = precedence[top], topRank >= rank {
                    output.append(operators.removeLast())
                }
                operators.append(token)
            } else if token == "(" {
                operators.append(token)
            } else if token == ")" {
                while let top = operators.popLast(), top != "(" {
                    output.append(top)
                }
            }
            // Spaces are skipped
        }
        flushNumber()
        while let top = operators.popLast() {
            output.append(top)
        }
        return output
    }

    public static func evaluate(postfix tokens: [String]) -> Int {
        var values: [Int] = []
        for token in tokens {
            // Check for an operator first: Int("-") is nil, but Int("-4") is a number
            guard precedence[token] != nil else {
                values.append(Int(token)!)
                continue
            }
            let right = values.removeLast()
            let left = values.removeLast()
            switch token {
            case "+": values.append(left + right)
            case "-": values.append(left - right)
            case "*": values.append(left * right)
            default: values.append(left / right)
            }
        }
        return values.last ?? 0
    }

    public static func calculate(_ expression: String) -> Int {
        evaluate(postfix: postfix(from: expression))
    }
}
