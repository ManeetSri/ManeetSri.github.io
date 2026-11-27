// Generated from src/dsa/content/lessons/complexity/bigo-amortised-methods.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Charge every append 3 coins and keep the change in a bank
var capacity = 1
var count = 0
var bank = 0
var balances: [Int] = []
for _ in 1...17 {
    var actual = 1                // write the new element
    if count == capacity {
        actual += count           // copy everything to a block twice the size
        capacity *= 2
    }
    count += 1
    bank += 3 - actual
    balances.append(bank)
}
print(balances)
print("lowest balance:", balances.min()!)
