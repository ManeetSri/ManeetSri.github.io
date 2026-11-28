// Generated from src/dsa/content/lessons/graph-basics/graph-implicit.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The neighbours of a combination: turn one wheel one step, up or down
func neighbours(of combination: String) -> [String] {
    let digits = combination.map { $0.wholeNumberValue! }
    var result: [String] = []
    for wheel in digits.indices {
        for step in [1, 9] {                         // +1, or −1 written as +9 so it stays positive
            var next = digits
            next[wheel] = (digits[wheel] + step) % 10
            result.append(next.map(String.init).joined())
        }
    }
    return result
}

print(neighbours(of: "0000"))
print(neighbours(of: "2909"))
