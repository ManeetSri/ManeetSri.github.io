// Generated from src/dsa/content/lessons/backtracking/bk-template.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var code: [Int] = []
var found: [String] = []

func explore(_ depth: Int) {
    if depth == 2 {
        found.append(code.map(String.init).joined())
        return
    }
    for digit in 1...3 where code.last != digit {
        code.append(digit)
        explore(depth + 1)
        // Bug: the code.removeLast() is missing
    }
}

explore(0)
print(found)
