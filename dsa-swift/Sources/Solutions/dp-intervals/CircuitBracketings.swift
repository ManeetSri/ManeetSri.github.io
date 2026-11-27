// Reference solution: Bracket a circuit. Interval DP that carries two counts per range: t[i][j] and
// f[i][j], the bracketings of symbols i...j that give true and false. Split at the operator evaluated
// last; every left bracketing pairs with every right one, so counts multiply, and the operator decides
// which pairs land in which count. `>` (implies) is the only operator that isn't symmetric: it's false
// only for true on the left and false on the right. Counts are kept modulo 1,000,000,007, adding up
// cases rather than subtracting. O(n³) time and O(n²) space for n symbols.

public enum CircuitBracketings {
    public static func count(_ expression: String, wanted: Bool) -> Int {
        let mod = 1_000_000_007
        let tokens = Array(expression)                               // symbol, operator, symbol, …
        let symbols = stride(from: 0, to: tokens.count, by: 2).map { tokens[$0] == "T" }
        let operators = stride(from: 1, to: tokens.count, by: 2).map { tokens[$0] }
        let n = symbols.count
        var t = Array(repeating: Array(repeating: 0, count: n), count: n)
        var f = Array(repeating: Array(repeating: 0, count: n), count: n)
        for i in 0..<n {
            t[i][i] = symbols[i] ? 1 : 0
            f[i][i] = symbols[i] ? 0 : 1
        }
        for length in stride(from: 2, through: n, by: 1) {
            for i in 0...(n - length) {
                let j = i + length - 1
                var trueWays = 0
                var falseWays = 0
                for k in i..<j {                                     // operators[k] is evaluated last
                    let (lt, lf, rt, rf) = (t[i][k], f[i][k], t[k + 1][j], f[k + 1][j])
                    let (tt, tf, ft, ff) = (lt * rt % mod, lt * rf % mod, lf * rt % mod, lf * rf % mod)
                    switch operators[k] {
                    case "&":
                        trueWays += tt
                        falseWays += tf + ft + ff
                    case "|":
                        trueWays += tt + tf + ft
                        falseWays += ff
                    case "^":
                        trueWays += tf + ft
                        falseWays += tt + ff
                    default:                                         // ">": false only for true > false
                        trueWays += tt + ft + ff
                        falseWays += tf
                    }
                    trueWays %= mod
                    falseWays %= mod
                }
                t[i][j] = trueWays
                f[i][j] = falseWays
            }
        }
        return wanted ? t[0][n - 1] : f[0][n - 1]
    }
}
