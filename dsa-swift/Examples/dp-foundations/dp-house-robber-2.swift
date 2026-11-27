// Generated from src/dsa/content/lessons/dp-foundations/dp-house-robber.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func rob(_ houses: [Int]) -> Int {
    let n = houses.count
    // 1. State: best[i] = the most you can take from the first i houses
    var best = Array(repeating: 0, count: n + 1)
    // 3. Base case: best[0] = 0 (no houses), already in place
    // 4. Order: upwards
    for i in stride(from: 1, through: n, by: 1) {
        // 2. Transition: leave house i - 1 alone, or rob it and skip its neighbour
        let skip = best[i - 1]
        let take = (i >= 2 ? best[i - 2] : 0) + houses[i - 1]
        best[i] = max(skip, take)
    }
    print("best:", best)
    // 5. Answer: all n houses considered
    return best[n]
}

print(rob([5, 8, 6, 1, 2, 9]))
print(rob([5, 1, 1, 5]))
