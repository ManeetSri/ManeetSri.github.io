// Generated from src/dsa/content/lessons/swift-closures/swift-map-filter-reduce.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let prices = [4, 10, 7]

var doubled: [Int] = []
for price in prices {
    doubled.append(price * 2)
}
print(doubled)

let alsoDoubled = prices.map { $0 * 2 }
print(alsoDoubled)
print(prices)
