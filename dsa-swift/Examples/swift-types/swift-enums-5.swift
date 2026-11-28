// Generated from src/dsa/content/lessons/swift-types/swift-enums.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

enum Coin: Int, CaseIterable {
    case penny = 1, nickel = 5, dime = 10, quarter = 25
}

print(Coin.allCases.count)
for coin in Coin.allCases {
    print(coin, coin.rawValue)
}
let total = Coin.allCases.reduce(0) { $0 + $1.rawValue }
print("One of each:", total)
