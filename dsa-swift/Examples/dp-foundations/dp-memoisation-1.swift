// Generated from src/dsa/content/lessons/dp-foundations/dp-memoisation.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var calls = 0

/// The cheapest energy to reach stone i, starting from stone 0
func cost(_ heights: [Int], _ i: Int) -> Int {
    calls += 1
    if i == 0 {
        return 0
    }
    var best = cost(heights, i - 1) + abs(heights[i] - heights[i - 1])
    if i >= 2 {
        best = min(best, cost(heights, i - 2) + abs(heights[i] - heights[i - 2]))
    }
    return best
}

let river = [10, 30, 40, 20, 50, 10]
print(cost(river, river.count - 1), "in", calls, "calls")

let wideRiver = (0..<30).map { ($0 * 37) % 50 }
calls = 0
print(cost(wideRiver, wideRiver.count - 1), "in", calls, "calls")
