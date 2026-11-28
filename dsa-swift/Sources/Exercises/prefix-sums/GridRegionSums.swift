// Problem: Grid region sums (M20 · 2D prefix sums and difference arrays)

public enum GridRegionSums {
    /// Answers sums over rectangles of a fixed grid.
    public struct Table {
        // Write your solution here, then run:
        // swift test --filter GridRegionSumsTests
        // Add whatever private storage you need.

        /// Prepares the table for `grid`, a rectangular grid indexed `grid[row][column]`.
        /// Aim for O(rows × columns).
        public init(_ grid: [[Int]]) {}

        /// The sum of every cell from row `top` to row `bottom` and from column `left` to column
        /// `right`, all inclusive. Aim for O(1).
        public func sum(top: Int, left: Int, bottom: Int, right: Int) -> Int {
            return 0
        }
    }
}
