// Generated from src/dsa/content/lessons/stacks/stack-calculator.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func calculateI(_ expression: String) -> Int {
    var result = 0
    var number = 0
    var sign = 1
    var saved: [(result: Int, sign: Int)] = []
    for character in expression {
        if let digit = character.wholeNumberValue {
            number = number * 10 + digit
        } else if character == "+" || character == "-" {
            result += sign * number               // the number before this sign is complete
            number = 0
            sign = character == "+" ? 1 : -1
        } else if character == "(" {
            saved.append((result, sign))          // remember everything outside the bracket
            result = 0
            sign = 1
        } else if character == ")" {
            result += sign * number
            number = 0
            let outer = saved.removeLast()
            result = outer.result + outer.sign * result
        }
    }
    return result + sign * number
}

for expression in ["1 + 1", " 2-1 + 2 ", "(1+(4+5+2)-3)+(6+8)", "-(2 + 3) + 10", "1 - (-2)", "10 - (4 - (3 - 1))"] {
    print("\(expression) = \(calculateI(expression))")
}
