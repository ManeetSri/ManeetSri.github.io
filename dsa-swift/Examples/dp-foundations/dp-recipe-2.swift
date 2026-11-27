// Generated from src/dsa/content/lessons/dp-foundations/dp-recipe.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// Questions must be taken in order. Answering question i scores points[i], but uses up the time
/// for the next rest[i] questions, which must be skipped. Passing a question costs nothing.
func bestScore(points: [Int], rest: [Int]) -> Int {
    let n = points.count
    // 1. State: best[i] = the most points available from questions i...n - 1
    // 3. Base case: best[n] = 0, with no questions left (the array starts at 0)
    var best = Array(repeating: 0, count: n + 1)
    // 4. Order: i decreases, because best[i] reads larger indexes
    for i in stride(from: n - 1, through: 0, by: -1) {
        // 2. Transition: pass question i, or answer it and jump past the ones it rules out
        let pass = best[i + 1]
        let answer = points[i] + best[min(n, i + 1 + rest[i])]
        best[i] = max(pass, answer)
    }
    print("best:", best)
    // 5. Answer: everything is still available at the start
    return best[0]
}

print(bestScore(points: [5, 2, 6, 1, 4, 3], rest: [1, 0, 2, 0, 1, 0]))
