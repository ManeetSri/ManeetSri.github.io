// Reference solution: Paint the regions. Backtracking: colour regions in order, trying each colour
// that no already-coloured neighbour uses, and undo when a later region runs out of options.
// Symmetry breaking: the colours are interchangeable, so a region may use at most one colour more than
// the largest used so far. That skips colourings that only rename colours, which matters most when
// the answer is "impossible" and every branch must be explored. Worst case O(mⁿ) time, O(n + E) space.

public enum RegionPainter {
    public static func colour(_ n: Int, _ borders: [[Int]], colours m: Int) -> [Int]? {
        var neighbours = [[Int]](repeating: [], count: n)
        for border in borders {
            neighbours[border[0]].append(border[1])
            neighbours[border[1]].append(border[0])
        }
        var colour = [Int](repeating: -1, count: n)

        func paint(_ region: Int, highestUsed: Int) -> Bool {
            if region == n { return true }
            for c in 0..<min(m, highestUsed + 2) {
                if neighbours[region].contains(where: { colour[$0] == c }) { continue }
                colour[region] = c
                if paint(region + 1, highestUsed: max(highestUsed, c)) { return true }
            }
            colour[region] = -1                        // undo before backing up
            return false
        }

        return paint(0, highestUsed: -1) ? colour : nil
    }
}
