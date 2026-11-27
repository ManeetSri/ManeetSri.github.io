// Generated from src/dsa/content/lessons/stacks/stack-calculator.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func calculateII(_ expression: String) -> Int {
    var terms: [Int] = []
    var number = 0
    var previous: Character = "+"            // the operator before `number`
    for character in expression + "+" {
        if let digit = character.wholeNumberValue {
            number = number * 10 + digit
        } else if "+-*/".contains(character) {
            switch previous {
            case "+": terms.append(number)
            case "-": terms.append(-number)
            case "*": terms.append(terms.removeLast() * number)
            default: terms.append(terms.removeLast() / number)
            }
            previous = character
            number = 0
        }
    }
    return terms.reduce(0, +)
}

for expression in ["3+2*2", " 3/2 ", "14 - 3/2", "2*3*4 - 10/3", "7"] {
    print("\(expression) = \(calculateII(expression))")
}
