// Generated from src/dsa/content/lessons/dp-foundations/dp-recipe.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// The number of ways to tile a 2 × n path with dominoes (either way round) and 2 × 2 squares
func tilings(_ n: Int) -> Int {
    // 1. State: ways[i] = the number of ways to tile the first i columns
    var ways = Array(repeating: 0, count: n + 1)
    // 3. Base case: one way to tile nothing (place no tiles)
    ways[0] = 1
    // 4. Order: i increases, because ways[i] reads ways[i - 1] and ways[i - 2]
    for i in stride(from: 1, through: n, by: 1) {
        // 2. Transition: what covers the last column?
        ways[i] = ways[i - 1]                          // one domino across it
        if i >= 2 {
            ways[i] += 2 * ways[i - 2]                 // two dominoes along, or one square, over the last two columns
        }
    }
    // 5. Answer
    return ways[n]
}

print((0...10).map(tilings))
