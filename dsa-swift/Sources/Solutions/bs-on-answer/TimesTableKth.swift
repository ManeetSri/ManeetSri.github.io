// Reference solution: The kth entry of a times table. Binary search on the value, not on positions. Row
// i holds i, 2i, …, columns × i, so it has min(x / i, columns) entries ≤ x, and the count of entries
// ≤ x never falls as x grows. The answer is the smallest x whose count reaches k. That x is always in
// the table: the count jumps between x − 1 and x, so some entry equals x. Looping over the shorter side
// makes each count O(min(rows, columns)): O(min(rows, columns) × log(rows × columns)) in total, O(1) space.

public enum TimesTableKth {
    public static func kthSmallest(rows: Int, columns: Int, k: Int) -> Int {
        let short = Swift.min(rows, columns)
        let long = Swift.max(rows, columns)              // the table is symmetric, so swapping is fine
        var low = 1
        var high = short * long                          // the largest entry
        while low < high {
            let mid = low + (high - low) / 2
            if entries(atMost: mid, short: short, long: long) >= k {
                high = mid
            } else {
                low = mid + 1
            }
        }
        return low
    }

    /// How many entries of the table are ≤ x.
    private static func entries(atMost x: Int, short: Int, long: Int) -> Int {
        var count = 0
        for i in 1...short {
            let inRow = x / i
            if inRow == 0 { break }                      // later rows start even higher
            count += Swift.min(inRow, long)
        }
        return count
    }
}
