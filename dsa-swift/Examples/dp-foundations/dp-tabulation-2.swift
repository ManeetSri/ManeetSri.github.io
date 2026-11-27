// Generated from src/dsa/content/lessons/dp-foundations/dp-tabulation.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let heights = [10, 30, 40, 20, 50, 10]
let n = heights.count

// Forwards. cost[i]: the cheapest way to reach stone i from stone 0
var cost = Array(repeating: 0, count: n)
for i in 1..<n {
    cost[i] = cost[i - 1] + abs(heights[i] - heights[i - 1])
    if i >= 2 {
        cost[i] = min(cost[i], cost[i - 2] + abs(heights[i] - heights[i - 2]))
    }
}
print("cost: ", cost, "answer", cost[n - 1])

// Backwards. toEnd[i]: the cheapest way from stone i to the last stone
var toEnd = Array(repeating: 0, count: n)
for i in stride(from: n - 2, through: 0, by: -1) {
    toEnd[i] = toEnd[i + 1] + abs(heights[i + 1] - heights[i])
    if i + 2 < n {
        toEnd[i] = min(toEnd[i], toEnd[i + 2] + abs(heights[i + 2] - heights[i]))
    }
}
print("toEnd:", toEnd, "answer", toEnd[0])
