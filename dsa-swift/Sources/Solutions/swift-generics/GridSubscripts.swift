// Reference solution: Grid with subscripts. One flat array in row-major order: row r, column c lives
// at r * columns + c. Both subscripts are O(1); row is O(columns) and column is O(rows).

public enum GridSubscripts {
    public struct Grid: Collection {
        public let rows: Int
        public let columns: Int
        private var cells: [Int]

        public init(rows: Int, columns: Int, repeating value: Int) {
            self.rows = rows
            self.columns = columns
            cells = Array(repeating: value, count: rows * columns)
        }

        public subscript(row: Int, column: Int) -> Int {
            get { cells[row * columns + column] }
            set { cells[row * columns + column] = newValue }
        }

        public func row(_ index: Int) -> [Int] {
            let start = index * columns
            return Array(cells[start..<start + columns])
        }

        public func column(_ index: Int) -> [Int] {
            (0..<rows).map { self[$0, index] }
        }

        // Collection: every cell, row by row. The positions are the flat array's indices.
        public var startIndex: Int { 0 }
        public var endIndex: Int { cells.count }

        public func index(after i: Int) -> Int {
            i + 1
        }

        public subscript(position: Int) -> Int {
            cells[position]
        }
    }
}
