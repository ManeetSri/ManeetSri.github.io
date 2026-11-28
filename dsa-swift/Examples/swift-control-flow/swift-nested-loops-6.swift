// Generated from src/dsa/content/lessons/swift-control-flow/swift-nested-loops.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let prices = [2, 7, 4, 5, 3]
let budget = 9
var pairs = 0

for i in 0..<prices.count {
    for j in (i + 1)..<prices.count {
        if prices[i] + prices[j] == budget {
            print("\(prices[i]) + \(prices[j])")
            pairs += 1
        }
    }
}
print("Pairs that cost exactly \(budget): \(pairs)")
