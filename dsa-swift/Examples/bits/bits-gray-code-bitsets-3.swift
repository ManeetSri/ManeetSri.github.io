// Generated from src/dsa/content/lessons/bits/bits-gray-code-bitsets.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let prices = [3, 1, 4, 2, 5]
let target = 7
var total = 0
var count = 0

for i in 1..<(1 << prices.count) {
    let item = i.trailingZeroBitCount
    let gray = i ^ (i >> 1)
    if gray & (1 << item) != 0 {
        total += prices[item]
    } else {
        total -= prices[item]
    }
    if total == target {
        count += 1
    }
}
print(count)
