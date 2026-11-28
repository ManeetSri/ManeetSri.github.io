// Reference solution: The last day to cross the field. Flooding only ever removes cells, which union-find
// can't do, so run time backwards: start from the field after every flood, then dry the cells out in
// reverse order. Drying only adds cells, and union-find handles additions well. Two extra elements stand
// for "the top row" and "the bottom row", and every dry cell in those rows joins them. The first moment
// (going backwards) that top and bottom are connected is the last day, going forwards, that a crossing
// exists. Binary search on the day with a BFS for each guess also works, in O(rc log rc).
// O(rc · α(rc)) time, O(rc) space.

import DSAKit

public enum LastDryCrossingDay {
    public static func lastDay(rows: Int, cols: Int, floods: [[Int]]) -> Int {
        let cells = rows * cols
        let top = cells
        let bottom = cells + 1
        var sets = UnionFind(count: cells + 2)
        var dry = Array(repeating: true, count: cells)
        for flood in floods {
            dry[flood[0] * cols + flood[1]] = false
        }

        func join(_ cell: Int) {
            let row = cell / cols
            let col = cell % cols
            if row == 0 { sets.union(cell, top) }
            if row == rows - 1 { sets.union(cell, bottom) }
            if row > 0, dry[cell - cols] { sets.union(cell, cell - cols) }
            if row < rows - 1, dry[cell + cols] { sets.union(cell, cell + cols) }
            if col > 0, dry[cell - 1] { sets.union(cell, cell - 1) }
            if col < cols - 1, dry[cell + 1] { sets.union(cell, cell + 1) }
        }

        // The field after every flood: only the cells that never flood are dry
        for cell in 0..<cells where dry[cell] {
            join(cell)
        }
        if sets.connected(top, bottom) { return floods.count }

        // Undo the floods from the last day back to the first
        for day in stride(from: floods.count, through: 1, by: -1) {
            let cell = floods[day - 1][0] * cols + floods[day - 1][1]
            dry[cell] = true
            join(cell)
            if sets.connected(top, bottom) { return day - 1 }   // the field after day - 1 floods
        }
        return 0                                                  // unreachable: a dry field can be crossed
    }
}
