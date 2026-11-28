// Reference solution: The most valuable bagful. Fractional knapsack: sort the goods by value per
// kilogram, densest first, comparing a.value · b.weight with b.value · a.weight so integer division
// never blurs two densities. Take each good whole while it fits, then a fraction of the first one that
// doesn't, and stop. An exchange argument (swap a kilogram of something less dense for a kilogram of
// the densest) proves it. O(n log n) time for the sort, O(n) space.

public enum SpiceMarketBagful {
    public static func bestValue(weights: [Int], values: [Int], capacity: Int) -> Double {
        let densestFirst = weights.indices.sorted { values[$0] * weights[$1] > values[$1] * weights[$0] }
        var room = capacity
        var total = 0.0
        for good in densestFirst {
            if room == 0 { break }
            let take = min(weights[good], room)
            total += Double(values[good]) * Double(take) / Double(weights[good])
            room -= take
        }
        return total
    }
}
