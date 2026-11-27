// Generated from src/dsa/content/lessons/dp-intervals/dpi-matrix-chain.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func bestBracketing(_ dims: [Int]) -> String {
    let n = dims.count - 1
    var cost = Array(repeating: Array(repeating: 0, count: n), count: n)
    var split = Array(repeating: Array(repeating: 0, count: n), count: n)   // the best k for each range
    if n >= 2 {
        for length in 2...n {
            for i in 0...(n - length) {
                let j = i + length - 1
                cost[i][j] = Int.max
                for k in i..<j {
                    let total = cost[i][k] + cost[k + 1][j] + dims[i] * dims[k + 1] * dims[j + 1]
                    if total < cost[i][j] {
                        cost[i][j] = total
                        split[i][j] = k
                    }
                }
            }
        }
    }

    func bracket(_ i: Int, _ j: Int) -> String {
        if i == j { return "A\(i + 1)" }
        let k = split[i][j]
        return "(" + bracket(i, k) + " " + bracket(k + 1, j) + ")"
    }

    return bracket(0, n - 1)
}

print(bestBracketing([10, 30, 5, 60, 10]))
print(bestBracketing([10, 30, 5, 60]))
print(bestBracketing([40, 20, 30, 10, 30]))
print(bestBracketing([7, 3]))
