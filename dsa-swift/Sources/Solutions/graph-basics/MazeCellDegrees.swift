// Reference solution: Dead ends and junctions. The maze is an implicit graph: every open cell is a
// vertex, and its edges go to the open cells directly above, below, left and right. Nothing is
// built; for each open cell, the four direction offsets generate its candidate neighbours, and the
// bounds and wall checks keep the real ones. The number kept is the cell's degree.
// O(rows × columns) time, and O(rows × columns) for a byte copy of the maze (O(1) beyond the input
// if you index the strings' UTF-8 views directly).

public enum MazeCellDegrees {
    public static func count(_ maze: [String]) -> [Int] {
        let cells = maze.map { Array($0.utf8) }
        let open = UInt8(ascii: ".")
        let directions = [(-1, 0), (1, 0), (0, -1), (0, 1)]
        var counts = [0, 0, 0, 0, 0]
        for row in cells.indices {
            for column in cells[row].indices where cells[row][column] == open {
                var degree = 0
                for (dr, dc) in directions {
                    let r = row + dr
                    let c = column + dc
                    if r >= 0, r < cells.count, c >= 0, c < cells[r].count, cells[r][c] == open {
                        degree += 1
                    }
                }
                counts[degree] += 1
            }
        }
        return counts
    }
}
