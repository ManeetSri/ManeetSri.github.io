// Reference solution: How many singers to watch first. The plan casts the best singer at position i > r
// exactly when the best of the first i − 1 is among the watched r, so the chance is
// (r / n) · (1/r + … + 1/(n − 1)) for r ≥ 1, and 1 / n for r = 0. A suffix sum of 1/j gives every r's
// chance in one O(n) pass, from which the first maximum is kept. O(n) time.

public enum SecretaryCutoffPlanner {
    public static func hire(scores: [Int], watch r: Int) -> Int? {
        var benchmark = Int.min
        for score in scores.prefix(r) {
            benchmark = max(benchmark, score)
        }
        for i in r..<scores.count where scores[i] > benchmark {
            return i
        }
        return nil
    }

    public static func successChance(candidates n: Int, watch r: Int) -> Double {
        if r == 0 { return 1.0 / Double(n) }
        var tail = 0.0                             // 1/r + 1/(r + 1) + … + 1/(n − 1), smallest first
        for j in stride(from: n - 1, through: r, by: -1) {
            tail += 1.0 / Double(j)
        }
        return Double(r) / Double(n) * tail
    }

    public static func bestWatchCount(candidates n: Int) -> Int {
        var best = n
        var bestChance = -1.0
        var tail = 0.0
        // Walk r downwards so the suffix sum grows one term at a time; ">=" keeps the smaller r on ties
        for r in stride(from: n, through: 1, by: -1) {
            if r <= n - 1 {
                tail += 1.0 / Double(r)
            }
            let chance = Double(r) / Double(n) * tail
            if chance >= bestChance {
                best = r
                bestChance = chance
            }
        }
        if 1.0 / Double(n) >= bestChance {        // r = 0: cast the first singer
            best = 0
        }
        return best
    }
}
