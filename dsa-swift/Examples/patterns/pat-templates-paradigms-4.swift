// Generated from src/dsa/content/lessons/patterns/pat-templates-paradigms.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// 0/1 knapsack in one row: the loop direction is the whole difference between "once" and "unlimited"
func bestValue(_ weights: [Int], _ values: [Int], capacity: Int, reuse: Bool) -> Int {
    var best = Array(repeating: 0, count: capacity + 1)      // best[c]: the most value within weight c
    for item in weights.indices {
        let w = weights[item]
        guard w <= capacity else { continue }
        // Downwards: best[c - w] still means "without this item", so each item is used at most once.
        // Upwards: best[c - w] may already include this item, so it can be taken again and again.
        let capacities = reuse ? Array(w...capacity) : Array((w...capacity).reversed())
        for c in capacities {
            best[c] = max(best[c], best[c - w] + values[item])
        }
    }
    return best[capacity]
}

let weights = [2, 3, 4]
let values = [3, 5, 6]
print("each item once:", bestValue(weights, values, capacity: 6, reuse: false))
print("unlimited copies:", bestValue(weights, values, capacity: 6, reuse: true))
