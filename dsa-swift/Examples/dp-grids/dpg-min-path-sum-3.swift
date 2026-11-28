// Generated from src/dsa/content/lessons/dp-grids/dpg-min-path-sum.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let triangle = [
    [5],
    [4, 7],
    [9, 8, 1],
    [2, 6, 3, 4],
]

// Greedy: always step to the smaller of the two numbers below
var position = 0
var greedyTotal = triangle[0][0]
for r in 1..<triangle.count {
    if triangle[r][position + 1] < triangle[r][position] {
        position += 1
    }
    greedyTotal += triangle[r][position]
}
print("greedy:", greedyTotal)

// Top-down: cost of the cheapest way from the apex to each position
var cost = [triangle[0][0]]
for r in 1..<triangle.count {
    var next = Array(repeating: 0, count: r + 1)
    for i in 0...r {
        let aboveLeft = i > 0 ? cost[i - 1] : Int.max     // the left end has no parent above-left
        let above = i < r ? cost[i] : Int.max             // the right end has no parent straight above
        next[i] = triangle[r][i] + min(aboveLeft, above)
    }
    cost = next
}
print("top-down:", cost.min()!, "from the last row", cost)

// Bottom-up: the base row is its own answer; climb towards the apex
var best = triangle[triangle.count - 1]
for r in stride(from: triangle.count - 2, through: 0, by: -1) {
    for i in 0...r {
        best[i] = triangle[r][i] + min(best[i], best[i + 1])
    }
}
print("bottom-up:", best[0])
