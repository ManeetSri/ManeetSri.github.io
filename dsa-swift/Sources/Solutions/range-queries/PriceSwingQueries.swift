// Reference solution: Price swing queries. The swing is max − min, and both are idempotent, so two
// sparse tables answer each query in O(1): low[j][i] and high[j][i] cover the 2^j prices from day i,
// and a query combines the block starting at left with the block ending at right, which overlap.
// O(n log n + q) time, O(n log n) space.

public enum PriceSwingQueries {
    public static func swings(prices: [Int], queries: [[Int]]) -> [Int] {
        let n = prices.count
        var floorLog = [Int](repeating: 0, count: n + 1)       // floorLog[x] = ⌊log₂ x⌋
        if n >= 2 {
            for x in 2...n {
                floorLog[x] = floorLog[x / 2] + 1
            }
        }

        var low = [prices]
        var high = [prices]
        var j = 1
        while (1 << j) <= n {
            let half = 1 << (j - 1)
            let previousLow = low[j - 1]
            let previousHigh = high[j - 1]
            let count = n - (1 << j) + 1
            low.append((0..<count).map { min(previousLow[$0], previousLow[$0 + half]) })
            high.append((0..<count).map { max(previousHigh[$0], previousHigh[$0 + half]) })
            j += 1
        }

        return queries.map { query in
            let left = query[0], right = query[1]
            let k = floorLog[right - left + 1]
            let other = right - (1 << k) + 1                     // the block that ends at right
            return max(high[k][left], high[k][other]) - min(low[k][left], low[k][other])
        }
    }
}
