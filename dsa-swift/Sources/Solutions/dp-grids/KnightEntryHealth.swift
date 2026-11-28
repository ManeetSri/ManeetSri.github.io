// Reference solution: A knight's minimum health. The rule (health stays at least 1) looks forward,
// so fill backwards from the princess: need[c] is the least health the knight can enter a cell with
// and still finish alive. need = max(1, min(need below, need right) - cell): take the easier way on,
// pay for this cell, and never ask for less than 1, because a potion can't lend health in advance.
// O(rows × cols) time, O(cols) space.

public enum KnightEntryHealth {
    public static func minimumHealth(_ dungeon: [[Int]]) -> Int {
        guard let cols = dungeon.first?.count, cols > 0 else { return 1 }
        let impossible = Int.max / 2
        // need[c] holds the row below (at first, an imaginary row past the grid); need[cols] is an
        // imaginary column past the right edge that stays impossible
        var need = Array(repeating: impossible, count: cols + 1)
        need[cols - 1] = 1                          // just past the goal, being alive is enough
        for r in stride(from: dungeon.count - 1, through: 0, by: -1) {
            for c in stride(from: cols - 1, through: 0, by: -1) {
                let onward = min(need[c], need[c + 1])  // below (still the old value) or right (updated)
                need[c] = max(1, onward - dungeon[r][c])
            }
        }
        return need[0]
    }
}
