// Generated from src/dsa/content/lessons/backtracking/bk-template.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func lockCodes(_ code: [Int], wheels: Int, digits: Int, into found: inout [[Int]]) {
    if code.count == wheels {
        found.append(code)
        return
    }
    for digit in 1...digits where code.last != digit {
        lockCodes(code + [digit], wheels: wheels, digits: digits, into: &found)   // a fresh array per child
    }
}

var found: [[Int]] = []
lockCodes([], wheels: 3, digits: 3, into: &found)
print(found.count, found.first!, found.last!)
