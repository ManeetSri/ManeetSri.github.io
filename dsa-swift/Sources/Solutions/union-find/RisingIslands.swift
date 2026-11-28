// Reference solution: Islands rising from the sea. Cell (r, c) is element r * columns + c of a
// union-find. When a cell becomes land it's a new island, so the count goes up by one; then it's
// unioned with each neighbouring land cell, and every union that joins two different islands brings
// the count down by one. A cell that's already land changes nothing. O(rows · columns + k α) time
// for k additions, O(rows · columns) space.

import DSAKit

public enum RisingIslands {
    public static func counts(rows: Int, columns: Int, _ land: [[Int]]) -> [Int] {
        var islands = UnionFind(count: rows * columns)
        var isLand = Array(repeating: false, count: rows * columns)
        var count = 0
        var result: [Int] = []
        result.reserveCapacity(land.count)
        for cell in land {
            let row = cell[0]
            let column = cell[1]
            let index = row * columns + column
            if !isLand[index] {
                isLand[index] = true
                count += 1
                for (dr, dc) in [(-1, 0), (1, 0), (0, -1), (0, 1)] {
                    let r = row + dr
                    let c = column + dc
                    guard r >= 0, r < rows, c >= 0, c < columns, isLand[r * columns + c] else { continue }
                    if islands.union(index, r * columns + c) {
                        count -= 1
                    }
                }
            }
            result.append(count)
        }
        return result
    }
}
