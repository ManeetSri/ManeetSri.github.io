// Generated from src/dsa/content/lessons/dp-knapsack/dpk-01.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// 0/1 knapsack in one row: O(n × capacity) time, O(capacity) memory
func knapsack(_ weights: [Int], _ values: [Int], _ capacity: Int) -> Int {
    var best = Array(repeating: 0, count: capacity + 1)   // best[w]: the most value with room w
    for (weight, value) in zip(weights, values) {
        // Right to left, so best[w - weight] still means "without this item"
        for w in stride(from: capacity, through: weight, by: -1) {
            best[w] = max(best[w], best[w - weight] + value)
        }
        print("after weight \(weight):", best)
    }
    return best[capacity]
}

print(knapsack([1, 3, 4, 5], [1, 4, 5, 7], 7))
print(knapsack([10], [99], 7))       // too heavy: the stride is empty, nothing breaks
