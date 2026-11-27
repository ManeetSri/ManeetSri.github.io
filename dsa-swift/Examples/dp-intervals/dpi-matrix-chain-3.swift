// Generated from src/dsa/content/lessons/dp-intervals/dpi-matrix-chain.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func cheapestChainMemo(_ dims: [Int]) -> Int {
    let n = dims.count - 1
    var memo = Array(repeating: Array(repeating: -1, count: n), count: n)   // -1: not solved yet

    func best(_ i: Int, _ j: Int) -> Int {
        if i == j { return 0 }
        if memo[i][j] != -1 { return memo[i][j] }
        var answer = Int.max
        for k in i..<j {
            answer = min(answer, best(i, k) + best(k + 1, j) + dims[i] * dims[k + 1] * dims[j + 1])
        }
        memo[i][j] = answer
        return answer
    }

    return best(0, n - 1)
}

print(cheapestChainMemo([10, 30, 5, 60, 10]))
print(cheapestChainMemo([10, 30, 5, 60]))
