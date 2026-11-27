// Generated from src/dsa/content/lessons/backtracking/bk-subsets.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let prices = [8, 3, 5, 9, 4, 7, 6, 2, 10, 1]
let budget = 12

// Bitmasks: look at all 2^n subsets and keep the affordable ones
var affordableByMask = 0
for mask in 0..<(1 << prices.count) {
    var total = 0
    for i in prices.indices where mask & (1 << i) != 0 {
        total += prices[i]
    }
    if total <= budget {
        affordableByMask += 1
    }
}
print("masks checked:", 1 << prices.count, "affordable:", affordableByMask)

// Backtracking over the sorted prices: a branch stops when the next price doesn't fit
let sorted = prices.sorted()
var nodes = 0
func explore(from start: Int, spent: Int) {
    nodes += 1                                   // every node is an affordable subset
    for i in start..<sorted.count {
        if spent + sorted[i] > budget { break }  // sorted, so every later price is too big as well
        explore(from: i + 1, spent: spent + sorted[i])
    }
}
explore(from: 0, spent: 0)
print("nodes visited:", nodes)
