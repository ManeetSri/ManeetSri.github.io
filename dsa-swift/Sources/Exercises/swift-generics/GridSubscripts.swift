// Problem: Grid with subscripts (M10 · Collection conformance and subscripts)

public enum GridSubscripts {
    /// A grid of whole numbers, stored in one flat array. As a Collection, it holds every cell
    /// row by row: all of row 0, then all of row 1, and so on.
    public struct Grid: Collection {
        public let rows: Int
        public let columns: Int

        // Write your solution here, then run:
        // swift test --filter GridSubscriptsTests
        // Add private storage, and fill it in the initialiser.

        /// A grid with `rows` rows and `columns` columns, every cell set to `value`.
        public init(rows: Int, columns: Int, repeating value: Int) {
            self.rows = rows
            self.columns = columns
        }

        /// Reads or writes the cell at `row`, `column`, used as `grid[row, column]`.
        public subscript(row: Int, column: Int) -> Int {
            get { return 0 }
            set { }
        }

        /// The cells of one row, from left to right.
        public func row(_ index: Int) -> [Int] {
            return []
        }

        /// The cells of one column, from top to bottom.
        public func column(_ index: Int) -> [Int] {
            return []
        }

        // Collection requirements: positions run from 0 to rows * columns, row by row.

        public var startIndex: Int {
            return 0
        }

        public var endIndex: Int {
            return 0
        }

        public func index(after i: Int) -> Int {
            return i + 1
        }

        public subscript(position: Int) -> Int {
            return 0
        }
    }
}
