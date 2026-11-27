// Problem: Orchard plot sums (M61 · 2D BIT)

public enum OrchardPlotSums {
    /// An orchard laid out as a grid of plots, each holding a count of fruit. Counts change as plots
    /// are harvested or replanted, and totals are asked for over rectangles of plots.
    public struct Orchard {
        // Write your solution here, then run:
        // swift test --filter OrchardPlotSumsTests
        // Add whatever private storage you need.

        /// Stores the orchard. `grid[r][c]` is the count in row r, column c; every row has the same
        /// length. Aim for O(rows × columns) or close to it.
        public init(_ grid: [[Int]]) {}

        /// Changes the count of one plot to `value`. Aim for O(log rows × log columns).
        public mutating func set(row: Int, column: Int, to value: Int) {}

        /// The total over the rectangle of plots from (top, left) to (bottom, right), inclusive.
        /// Aim for O(log rows × log columns).
        public func total(top: Int, left: Int, bottom: Int, right: Int) -> Int {
            return 0
        }
    }
}
