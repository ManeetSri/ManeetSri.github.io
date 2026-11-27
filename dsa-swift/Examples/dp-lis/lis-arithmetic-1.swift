// Generated from src/dsa/content/lessons/dp-lis/lis-arithmetic.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func maxSumIncreasing(_ items: [Int]) -> Int {
    var best = items                                   // each element alone
    for i in items.indices {
        for j in 0..<i where items[j] < items[i] {
            best[i] = max(best[i], best[j] + items[i])
        }
    }
    print("best:", best)
    return best.max() ?? 0
}

print(maxSumIncreasing([4, 101, 2, 3, 100, 5, 6, 7]))
