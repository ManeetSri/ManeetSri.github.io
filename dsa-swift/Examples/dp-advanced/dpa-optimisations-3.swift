// Generated from src/dsa/content/lessons/dp-advanced/dpa-optimisations.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Merge a row of piles into one, two neighbours at a time. Each merge costs the size of the new pile.
// cost[i][j] = min over split k of cost[i][k] + cost[k + 1][j], plus sum(i...j)
func mergeCost(_ piles: [Int], knuth: Bool) -> (cost: Int, steps: Int) {
    let n = piles.count
    var prefix = [0]
    for p in piles { prefix.append(prefix.last! + p) }
    var cost = [[Int]](repeating: [Int](repeating: 0, count: n), count: n)
    var opt = [[Int]](repeating: [Int](repeating: 0, count: n), count: n)   // the best split k for i...j
    for i in 0..<n { opt[i][i] = i }
    var steps = 0
    for length in 2...n {
        for i in 0...(n - length) {
            let j = i + length - 1
            // Knuth: the best split lies between the best splits of the two ranges one shorter
            let low = knuth ? opt[i][j - 1] : i
            let high = knuth ? min(opt[i + 1][j], j - 1) : j - 1
            cost[i][j] = Int.max
            for k in low...high {
                steps += 1
                let candidate = cost[i][k] + cost[k + 1][j]
                if candidate < cost[i][j] {
                    cost[i][j] = candidate
                    opt[i][j] = k
                }
            }
            cost[i][j] += prefix[j + 1] - prefix[i]
        }
    }
    return (cost[0][n - 1], steps)
}

let piles = [4, 1, 3, 6, 2]
print(mergeCost(piles, knuth: false).cost, mergeCost(piles, knuth: true).cost)
let row = (0..<200).map { ($0 * 53 + 7) % 40 + 1 }
let plain = mergeCost(row, knuth: false), fast = mergeCost(row, knuth: true)
print(plain.cost, fast.cost)
print("splits tried:", plain.steps, "vs", fast.steps)
