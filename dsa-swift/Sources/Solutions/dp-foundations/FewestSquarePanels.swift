// Reference solution: Fewest square panels. fewest[t] = the fewest perfect squares adding up to t,
// with fewest[0] = 0 and fewest[t] = 1 + the minimum of fewest[t - k²] over every square k² ≤ t.
// Each square can be reused, like unlimited coins. O(n √n) time, O(n) space.
// (Lagrange and Legendre's theorems give an O(√n) shortcut: the answer is at most 4.)

public enum FewestSquarePanels {
    public static func fewestPanels(tiles: Int) -> Int {
        var fewest = Array(repeating: Int.max, count: tiles + 1)
        fewest[0] = 0
        for total in stride(from: 1, through: tiles, by: 1) {
            var side = 1
            while side * side <= total {
                fewest[total] = min(fewest[total], fewest[total - side * side] + 1)
                side += 1
            }
        }
        return fewest[tiles]
    }
}
