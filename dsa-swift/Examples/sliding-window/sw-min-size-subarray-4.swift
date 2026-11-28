// Generated from src/dsa/content/lessons/sliding-window/sw-min-size-subarray.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func longestWithinBudget(_ costs: [Int], budget: Int) -> Int {
    var left = 0
    var sum = 0
    var best = 0
    for right in 0..<costs.count {
        sum += costs[right]
        while sum > budget {
            sum -= costs[left]
            left += 1
        }
        best = max(best, right - left + 1)
    }
    return best
}

print(longestWithinBudget([3, 1, 2, 7, 1, 1, 2], budget: 5))
print(longestWithinBudget([9, 9], budget: 5))
