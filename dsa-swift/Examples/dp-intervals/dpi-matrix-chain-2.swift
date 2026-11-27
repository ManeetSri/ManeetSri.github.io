// Generated from src/dsa/content/lessons/dp-intervals/dpi-matrix-chain.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func cheapestChain(_ dims: [Int]) -> [[Int]] {
    let n = dims.count - 1                                          // matrix i is dims[i] × dims[i + 1]
    var cost = Array(repeating: Array(repeating: 0, count: n), count: n)
    if n < 2 { return cost }
    for length in 2...n {                                           // shorter ranges first
        for i in 0...(n - length) {
            let j = i + length - 1
            cost[i][j] = Int.max
            for k in i..<j {                                        // last multiplication: (i...k)(k+1...j)
                let total = cost[i][k] + cost[k + 1][j] + dims[i] * dims[k + 1] * dims[j + 1]
                cost[i][j] = min(cost[i][j], total)
            }
        }
    }
    return cost
}

let cost = cheapestChain([10, 30, 5, 60, 10])
for row in cost {
    print(row)
}
print("whole chain:", cost[0][3])
