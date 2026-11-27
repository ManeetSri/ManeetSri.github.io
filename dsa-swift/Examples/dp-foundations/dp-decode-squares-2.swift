// Generated from src/dsa/content/lessons/dp-foundations/dp-decode-squares.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// The fewest perfect squares (1, 4, 9, 16, ...) that add up to n
func fewestSquares(_ n: Int) -> Int {
    // 1. State: fewest[t] = the fewest perfect squares that add up to t
    var fewest = Array(repeating: Int.max, count: n + 1)
    // 3. Base case: 0 is the sum of no squares
    fewest[0] = 0
    // 4. Order: upwards, because fewest[t] reads smaller totals
    for t in stride(from: 1, through: n, by: 1) {
        // 2. Transition: try every square that fits as the last one
        var root = 1
        while root * root <= t {
            fewest[t] = min(fewest[t], fewest[t - root * root] + 1)
            root += 1
        }
    }
    // 5. Answer
    return fewest[n]
}

print((1...20).map(fewestSquares))
print(fewestSquares(12), fewestSquares(13), fewestSquares(9_999))
