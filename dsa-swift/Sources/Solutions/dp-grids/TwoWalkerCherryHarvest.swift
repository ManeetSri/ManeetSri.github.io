// Reference solution: Two-walker cherry harvest. The walk back is a second walk forwards, so two
// walkers go from the top-left to the bottom-right together. After `step` moves each, a walker in row r
// is in column step - r, so the state is (step, r1, r2), and the walkers share a cell exactly when
// r1 == r2. Each walker arrived from above or from the left: four previous states. Thorns and
// unreachable states are "impossible". O(n³) time, O(n²) space (one step at a time).

public enum TwoWalkerCherryHarvest {
    public static func maxCherries(_ orchard: [[Int]]) -> Int {
        let n = orchard.count
        guard n > 0, orchard[0][0] != -1 else { return 0 }
        let impossible = Int.min / 2
        // best[r1][r2]: the most cherries after `step` moves each, with the walkers in rows r1 and r2
        var best = Array(repeating: Array(repeating: impossible, count: n), count: n)
        best[0][0] = orchard[0][0]
        for step in stride(from: 1, through: 2 * n - 2, by: 1) {
            var next = Array(repeating: Array(repeating: impossible, count: n), count: n)
            let rows = max(0, step - (n - 1))...min(n - 1, step)     // rows whose column is inside the grid
            for r1 in rows where orchard[r1][step - r1] != -1 {
                for r2 in rows where orchard[r2][step - r2] != -1 {
                    var before = best[r1][r2]                                // both came from the left
                    if r1 > 0 { before = max(before, best[r1 - 1][r2]) }     // walker one from above
                    if r2 > 0 { before = max(before, best[r1][r2 - 1]) }     // walker two from above
                    if r1 > 0 && r2 > 0 { before = max(before, best[r1 - 1][r2 - 1]) }
                    if before == impossible { continue }
                    let here = orchard[r1][step - r1]
                    next[r1][r2] = before + (r1 == r2 ? here : here + orchard[r2][step - r2])   // a shared cell counts once
                }
            }
            best = next
        }
        return max(0, best[n - 1][n - 1])
    }
}
