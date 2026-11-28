// Generated from src/dsa/content/lessons/dp-knapsack/dpk-01.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let weights = [1, 3, 4, 5]
let values = [1, 4, 5, 7]
let capacity = 7
let n = weights.count

var best = Array(repeating: Array(repeating: 0, count: capacity + 1), count: n + 1)
for i in 1...n {
    for w in 0...capacity {
        best[i][w] = best[i - 1][w]
        if weights[i - 1] <= w {
            best[i][w] = max(best[i][w], best[i - 1][w - weights[i - 1]] + values[i - 1])
        }
    }
}

// Walk back from the answer cell. If the row above has the same value, item i wasn't needed.
var chosen: [Int] = []
var w = capacity
for i in stride(from: n, through: 1, by: -1) {
    if best[i][w] == best[i - 1][w] {
        print("row \(i), room \(w): \(best[i][w]) is also above, so skip index \(i - 1)")
    } else {
        print("row \(i), room \(w): \(best[i][w]) beats \(best[i - 1][w]) above, so take index \(i - 1)")
        chosen.append(i - 1)
        w -= weights[i - 1]
    }
}
chosen.reverse()
print("indices:", chosen)
print("weight", chosen.map { weights[$0] }.reduce(0, +), "value", chosen.map { values[$0] }.reduce(0, +))
