// Generated from src/dsa/content/lessons/bits/bits-subsets.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let prices = [3, 1, 4, 2, 5]
let target = 7
var count = 0

for mask in 0..<(1 << prices.count) {
    var total = 0
    var chosen: [Int] = []
    var rest = mask
    while rest != 0 {
        let i = rest.trailingZeroBitCount
        total += prices[i]
        chosen.append(prices[i])
        rest &= rest - 1
    }
    if total == target {
        print(chosen)
        count += 1
    }
}
print("\(count) ways to spend exactly \(target)")
