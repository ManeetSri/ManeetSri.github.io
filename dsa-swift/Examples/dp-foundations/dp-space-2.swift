// Generated from src/dsa/content/lessons/dp-foundations/dp-space.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func cheapestCrossing(_ heights: [Int]) -> Int {
    var twoBack = 0                    // the cheapest way to reach stone i - 2
    var oneBack = 0                    // the cheapest way to reach stone i - 1
    for i in 1..<heights.count {
        var best = oneBack + abs(heights[i] - heights[i - 1])
        if i >= 2 {
            best = min(best, twoBack + abs(heights[i] - heights[i - 2]))
        }
        (twoBack, oneBack) = (oneBack, best)
    }
    return oneBack
}

print(cheapestCrossing([10, 30, 40, 20, 50, 10]))
print(cheapestCrossing([7]))
print(cheapestCrossing((0..<1_000_000).map { ($0 * 7919) % 1000 }))
