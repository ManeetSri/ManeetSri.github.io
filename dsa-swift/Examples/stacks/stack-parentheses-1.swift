// Generated from src/dsa/content/lessons/stacks/stack-parentheses.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func isBalancedRound(_ text: String) -> Bool {
    var open = 0
    for character in text {
        if character == "(" {
            open += 1
        } else if character == ")" {
            open -= 1
            if open < 0 {
                return false           // a ) with nothing to close
            }
        }
    }
    return open == 0
}

for text in ["(a(b)c)", "(()", "())(", ""] {
    print(text.isEmpty ? "(empty)" : text, isBalancedRound(text))
}
