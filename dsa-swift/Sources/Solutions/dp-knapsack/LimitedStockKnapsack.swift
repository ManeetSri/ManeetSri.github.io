// Reference solution: Limited-stock knapsack. Cap each stock at capacity / weight (more copies can never
// fit), split it into bundles of 1, 2, 4, … copies plus a remainder, so that every count from 0 to the
// stock is a sum of some bundles, and run the one-row 0/1 knapsack over the bundles.
// O(capacity · Σ log stock) time, O(capacity) space.

public enum LimitedStockKnapsack {
    public static func bestValue(weights: [Int], values: [Int], stock: [Int], capacity: Int) -> Int {
        var best = Array(repeating: 0, count: capacity + 1)
        for kind in weights.indices {
            var left = min(stock[kind], capacity / weights[kind])
            var size = 1
            while left > 0 {
                let bundle = min(size, left)                         // 1, 2, 4, … then the remainder
                let weight = bundle * weights[kind]
                let value = bundle * values[kind]
                for w in stride(from: capacity, through: weight, by: -1) {
                    best[w] = max(best[w], best[w - weight] + value)
                }
                left -= bundle
                size *= 2
            }
        }
        return best[capacity]
    }
}
