// Generated from src/dsa/content/lessons/dp-intervals/dpi-boolean.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func countWays(_ expression: String) -> (trueWays: Int, falseWays: Int) {
    let tokens = Array(expression)                                   // symbol, operator, symbol, …
    let symbols = stride(from: 0, to: tokens.count, by: 2).map { tokens[$0] == "T" }
    let operators = stride(from: 1, to: tokens.count, by: 2).map { tokens[$0] }
    let n = symbols.count
    var t = Array(repeating: Array(repeating: 0, count: n), count: n)
    var f = Array(repeating: Array(repeating: 0, count: n), count: n)
    for i in 0..<n {
        t[i][i] = symbols[i] ? 1 : 0
        f[i][i] = symbols[i] ? 0 : 1
    }
    if n >= 2 {
        for length in 2...n {
            for i in 0...(n - length) {
                let j = i + length - 1
                for k in i..<j {                                     // operators[k] is evaluated last
                    let (lt, lf, rt, rf) = (t[i][k], f[i][k], t[k + 1][j], f[k + 1][j])
                    switch operators[k] {
                    case "&":
                        t[i][j] += lt * rt
                        f[i][j] += lt * rf + lf * rt + lf * rf
                    case "|":
                        t[i][j] += lt * rt + lt * rf + lf * rt
                        f[i][j] += lf * rf
                    default:                                         // "^"
                        t[i][j] += lt * rf + lf * rt
                        f[i][j] += lt * rt + lf * rf
                    }
                }
            }
        }
    }
    return (t[0][n - 1], f[0][n - 1])
}

print(countWays("T^T&F|T"))
print(countWays("T|F&F^T"))
print(countWays("T"))
