// Generated from src/dsa/content/lessons/greedy/greedy-idea.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func greedySpend(_ prices: [Int], budget: Int) -> Int {
    var left = budget
    for price in prices.sorted(by: >) where price <= left {
        left -= price
    }
    return budget - left
}

// Try every subset of the items (fine for a handful)
func bestSpend(_ prices: [Int], budget: Int) -> Int {
    var best = 0
    for mask in 0..<(1 << prices.count) {
        let total = prices.indices.filter { mask & (1 << $0) != 0 }.reduce(0) { $0 + prices[$1] }
        if total <= budget { best = max(best, total) }
    }
    return best
}

print(greedySpend([6, 5, 5], budget: 10), bestSpend([6, 5, 5], budget: 10))
print(greedySpend([8, 6, 3], budget: 9), bestSpend([8, 6, 3], budget: 9))
