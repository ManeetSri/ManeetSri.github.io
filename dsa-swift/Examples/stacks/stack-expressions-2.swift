// Generated from src/dsa/content/lessons/stacks/stack-expressions.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func tokens(_ expression: String) -> [String] {
    var result: [String] = []
    var number = ""
    for character in expression {
        if character.isWholeNumber {
            number.append(character)            // keep collecting digits
            continue
        }
        if !number.isEmpty {
            result.append(number)               // the number has ended
            number = ""
        }
        if character != " " {
            result.append(String(character))
        }
    }
    if !number.isEmpty {
        result.append(number)
    }
    return result
}

let precedence: [String: Int] = ["+": 1, "-": 1, "*": 2, "/": 2]

func toPostfix(_ expression: String) -> [String] {
    var output: [String] = []
    var operators: [String] = []
    for token in tokens(expression) {
        if let rank = precedence[token] {
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
        } else {
            output.append(token)                     // a number
        }
    }
    while let top = operators.popLast() {
        output.append(top)
    }
    return output
}

print(tokens("12/(2+4)*3"))
for expression in ["3 + 4 * 2", "(3 + 4) * 2", "8 - 3 - 2", "3 + 4 * 2 - (1 + 5)"] {
    print("\(expression)  ->  \(toPostfix(expression).joined(separator: " "))")
}
