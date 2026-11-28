// Generated from src/dsa/content/lessons/backtracking/bk-template.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func lockCodes(wheels: Int, digits: Int) -> [[Int]] {
    var code: [Int] = []
    var found: [[Int]] = []

    func explore() {
        if code.count == wheels {
            found.append(code)
            return
        }
        for digit in 1...digits where code.last != digit {
            code.append(digit)             // choose
            explore()                      // explore
            code.removeLast()              // unchoose
        }
    }

    explore()
    return found
}

print(lockCodes(wheels: 2, digits: 3))
print(lockCodes(wheels: 4, digits: 2))
