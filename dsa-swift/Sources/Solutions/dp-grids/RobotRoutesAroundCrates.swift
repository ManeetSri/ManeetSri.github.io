// Reference solution: Robot routes around crates. Every route into a cell arrives from above or
// from the left, so routes[r][c] = routes[r - 1][c] + routes[r][c - 1], with crates holding 0. One
// row is enough: before the update, row[c] still holds the count from above, and row[c - 1] already
// holds this row's count to the left. O(rows × cols) time, O(cols) space.

public enum RobotRoutesAroundCrates {
    public static func routes(_ floor: [[Int]]) -> Int {
        guard let cols = floor.first?.count, cols > 0 else { return 0 }
        var row = Array(repeating: 0, count: cols)
        row[0] = 1                                  // the route that starts at the start
        for cells in floor {
            for c in 0..<cols {
                if cells[c] == 1 {
                    row[c] = 0                      // nothing passes through a crate
                } else if c > 0 {
                    row[c] += row[c - 1]            // from above (already in row[c]) plus from the left
                }
            }
        }
        return row[cols - 1]
    }
}
