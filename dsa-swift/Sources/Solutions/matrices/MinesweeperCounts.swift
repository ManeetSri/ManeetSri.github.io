// Reference solution: Minesweeper counts. Turn the rows into character arrays for O(1) indexing, then
// for each empty cell try the eight moves in a direction array, skipping any that leave the field.
// O(rows × columns) time: eight checks per cell.

public enum MinesweeperCounts {
    private static let moves = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)]

    public static func annotate(_ field: [String]) -> [String] {
        let cells = field.map { Array($0) }
        let rows = cells.count
        var result: [String] = []
        result.reserveCapacity(rows)

        for row in 0..<rows {
            let columns = cells[row].count
            var line = ""
            for column in 0..<columns {
                if cells[row][column] == "*" {
                    line.append("*")
                    continue
                }
                var mines = 0
                for (dr, dc) in moves {
                    let r = row + dr
                    let c = column + dc
                    if r >= 0 && r < rows && c >= 0 && c < cells[r].count && cells[r][c] == "*" {
                        mines += 1
                    }
                }
                line += String(mines)
            }
            result.append(line)
        }
        return result
    }
}
