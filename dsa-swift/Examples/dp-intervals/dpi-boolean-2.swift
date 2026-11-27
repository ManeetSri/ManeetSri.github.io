// Generated from src/dsa/content/lessons/dp-intervals/dpi-boolean.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func totalBracketings(_ operatorCount: Int) -> Int {
    var catalan = [1]
    for size in stride(from: 1, through: operatorCount, by: 1) {
        var total = 0
        for left in 0..<size {
            total += catalan[left] * catalan[size - 1 - left]   // operators on each side of the last one
        }
        catalan.append(total)
    }
    return catalan[operatorCount]
}

print(2 + 3 == totalBracketings(3))   // T^T&F|T has 3 operators: 2 true and 3 false bracketings
print(totalBracketings(5))            // every expression with 5 operators has this many
