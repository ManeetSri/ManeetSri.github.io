// Reference solution: Ribbon printer turns. Collapse runs of equal letters first (a run never costs
// more than one letter). turns[i][j] is the fewest turns for letters i...j. The leftmost letter either
// gets a turn of its own, 1 + turns[i + 1][j], or shares a turn with a later equal letter k, which is
// stretched left to cover it: turns[i + 1][k - 1] + turns[k][j]. Rows are filled from the bottom up.
// O(n³) time, O(n²) space.

public enum RibbonPrinterTurns {
    public static func fewestTurns(_ pattern: String) -> Int {
        var s: [Character] = []
        for letter in pattern where s.last != letter {
            s.append(letter)
        }
        let n = s.count
        guard n > 0 else { return 0 }
        var turns = Array(repeating: Array(repeating: 0, count: n), count: n)
        for i in stride(from: n - 1, through: 0, by: -1) {
            turns[i][i] = 1
            for j in stride(from: i + 1, to: n, by: 1) {
                var fewest = 1 + turns[i + 1][j]
                for k in stride(from: i + 2, through: j, by: 1) where s[k] == s[i] {
                    fewest = min(fewest, turns[i + 1][k - 1] + turns[k][j])
                }
                turns[i][j] = fewest
            }
        }
        return turns[0][n - 1]
    }
}
