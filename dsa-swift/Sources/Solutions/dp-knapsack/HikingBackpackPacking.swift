// Reference solution: Pack the hiking backpack. The 0/1 knapsack table best[i][w] (the most value
// from the first i items with room w), then a walk back from best[n][capacity]: whenever a cell beats
// the one above it, item i was packed. O(n · capacity) time and space.

public enum HikingBackpackPacking {
    public static func bestPack(weights: [Int], values: [Int], capacity: Int) -> [Int] {
        let n = weights.count
        var best = Array(repeating: Array(repeating: 0, count: capacity + 1), count: n + 1)
        for i in stride(from: 1, through: n, by: 1) {
            let weight = weights[i - 1]
            let value = values[i - 1]
            for w in 0...capacity {
                best[i][w] = best[i - 1][w]                          // leave item i behind
                if weight <= w {
                    best[i][w] = max(best[i][w], best[i - 1][w - weight] + value)   // or pack it
                }
            }
        }
        var packed: [Int] = []
        var room = capacity
        for i in stride(from: n, through: 1, by: -1) where best[i][room] != best[i - 1][room] {
            packed.append(i - 1)
            room -= weights[i - 1]
        }
        return packed.reversed()
    }
}
