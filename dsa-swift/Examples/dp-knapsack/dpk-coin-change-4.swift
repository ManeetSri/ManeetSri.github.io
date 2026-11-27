// Generated from src/dsa/content/lessons/dp-knapsack/dpk-coin-change.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// List every way to make 4 from coins 1, 2 and 3, as an ordered sequence
func sequences(_ amount: Int, _ coins: [Int]) -> [[Int]] {
    if amount == 0 { return [[]] }
    var result: [[Int]] = []
    for coin in coins where coin <= amount {
        for rest in sequences(amount - coin, coins) {
            result.append([coin] + rest)
        }
    }
    return result
}

let all = sequences(4, [1, 2, 3])
print("ordered:", all.count)
for way in all {
    print("  " + way.map(String.init).joined(separator: " + "))
}
let unordered = Set(all.map { $0.sorted() })
print("ignoring order:", unordered.count)
for way in unordered.sorted(by: { $0.lexicographicallyPrecedes($1) }) {
    print("  " + way.map(String.init).joined(separator: " + "))
}
