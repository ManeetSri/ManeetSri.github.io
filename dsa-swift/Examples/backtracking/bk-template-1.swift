// Generated from src/dsa/content/lessons/backtracking/bk-template.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var code: [Int] = []                       // the state: the path from the root to here
var found: [[Int]] = []

func explore() {
    if code.count == 3 {                   // goal: a complete code
        found.append(code)
        return
    }
    for digit in 1...3 {
        if code.last == digit { continue } // constraint: skip this branch entirely
        code.append(digit)                 // choose
        explore()                          // explore everything below this choice
        code.removeLast()                  // unchoose: put the state back
    }
}

explore()
print(found.count, "codes")
print(found.prefix(4).map { $0.map(String.init).joined() })
