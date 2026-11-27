// Reference solution: price band totals. The slow version scans every price for every band. Sorting
// the prices once puts each band's prices in one contiguous run, two binary searches find the run's
// ends, and prefix sums add the run in O(1). O((n + q) log n) time and O(n) extra space.

public enum PriceBandTotals {
    public static func totals(prices: [Int], bands: [(low: Int, high: Int)]) -> [Int] {
        let sorted = prices.sorted()
        var prefix = [0]                         // prefix[i] = sum of the i smallest prices
        prefix.reserveCapacity(sorted.count + 1)
        for price in sorted {
            prefix.append(prefix[prefix.count - 1] + price)
        }
        return bands.map { band in
            guard band.low <= band.high else { return 0 }
            let first = firstIndex(in: sorted) { $0 >= band.low }
            let end = firstIndex(in: sorted) { $0 > band.high }
            return prefix[end] - prefix[first]
        }
    }

    /// The first index whose value satisfies `isAtOrPast`, or `values.count`. The predicate must be
    /// false and then true along the sorted array.
    private static func firstIndex(in values: [Int], where isAtOrPast: (Int) -> Bool) -> Int {
        var low = 0
        var high = values.count
        while low < high {
            let mid = low + (high - low) / 2
            if isAtOrPast(values[mid]) {
                high = mid
            } else {
                low = mid + 1
            }
        }
        return low
    }
}
