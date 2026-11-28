// Generated from src/dsa/content/lessons/dp-knapsack/dpk-01.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let weights = [1, 3, 4, 5]
let values = [1, 4, 5, 7]
let capacity = 7
let n = weights.count

// best[i][w]: the most value using only the first i items, with room w
var best = Array(repeating: Array(repeating: 0, count: capacity + 1), count: n + 1)
for i in 1...n {
    let weight = weights[i - 1]                     // item i lives at index i - 1
    let value = values[i - 1]
    for w in 0...capacity {
        best[i][w] = best[i - 1][w]                 // skip item i
        if weight <= w {                            // or take it, if it fits
            best[i][w] = max(best[i][w], best[i - 1][w - weight] + value)
        }
    }
}

print("room:    ", (0...capacity).map { String($0) }.joined(separator: "  "))
for i in 0...n {
    print("first \(i): ", best[i].map { String($0) }.joined(separator: "  "))
}
print("answer:", best[n][capacity])
