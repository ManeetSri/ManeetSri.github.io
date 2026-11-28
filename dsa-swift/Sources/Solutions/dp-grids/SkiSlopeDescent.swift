// Reference solution: The cheapest ski run. best[c] is the cheapest run that ends in column c of the
// current row. A cell's parents are the up-to-three cells above it, so each row takes the minimum over
// columns max(0, c - 1)...min(cols - 1, c + 1) of the previous row. That reads the previous row's
// left neighbour, which an in-place update would already have overwritten, so keep two rows.
// O(rows × cols) time, O(cols) space.

public enum SkiSlopeDescent {
    public static func cheapestRun(_ slope: [[Int]]) -> Int {
        guard var previous = slope.first, !previous.isEmpty else { return 0 }
        let cols = previous.count
        var current = Array(repeating: 0, count: cols)
        for row in slope.dropFirst() {
            for c in 0..<cols {
                current[c] = row[c] + previous[max(0, c - 1)...min(cols - 1, c + 1)].min()!
            }
            swap(&previous, &current)
        }
        return previous.min()!
    }
}
