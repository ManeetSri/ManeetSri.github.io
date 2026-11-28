// Generated from src/dsa/content/lessons/dp-knapsack/dpk-01.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let weights = [1, 3, 4, 5]
let values = [1, 4, 5, 7]
let capacity = 7
let n = weights.count

var bestValue = 0
var bestMask = 0
for mask in 0..<(1 << n) {                          // every subset, as a bitmask
    var weight = 0
    var value = 0
    for i in 0..<n where mask & (1 << i) != 0 {
        weight += weights[i]
        value += values[i]
    }
    if weight <= capacity && value > bestValue {
        bestValue = value
        bestMask = mask
    }
}
print("subsets tried:", 1 << n)
print("best value:", bestValue)
print("items:", (0..<n).filter { bestMask & (1 << $0) != 0 })
