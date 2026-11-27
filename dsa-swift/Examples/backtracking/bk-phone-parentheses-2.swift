// Generated from src/dsa/content/lessons/backtracking/bk-phone-parentheses.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func balancedBrackets(_ n: Int) -> [String] {
    var current: [Character] = []
    var result: [String] = []

    func explore(open: Int, close: Int) {
        if current.count == 2 * n {
            result.append(String(current))
            return
        }
        if open < n {                            // room for another "("
            current.append("(")
            explore(open: open + 1, close: close)
            current.removeLast()
        }
        if close < open {                        // an unmatched "(" to close
            current.append(")")
            explore(open: open, close: close + 1)
            current.removeLast()
        }
    }

    explore(open: 0, close: 0)
    return result
}

print(balancedBrackets(3))
