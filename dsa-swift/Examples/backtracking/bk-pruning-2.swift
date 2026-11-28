// Generated from src/dsa/content/lessons/backtracking/bk-pruning.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let coins = [1, 2, 5, 10]

func countWays(_ amount: Int, memoise: Bool) -> (ways: Int, calls: Int) {
    var calls = 0
    var memo: [Int: Int] = [:]                                   // key: index * (amount + 1) + remaining
    func ways(_ index: Int, _ remaining: Int) -> Int {
        calls += 1
        if remaining == 0 { return 1 }
        if index == coins.count || remaining < 0 { return 0 }
        let key = index * (amount + 1) + remaining
        if memoise, let known = memo[key] { return known }
        // Use coins[index] once more (and stay on it), or move past it for good
        let total = ways(index, remaining - coins[index]) + ways(index + 1, remaining)
        if memoise { memo[key] = total }
        return total
    }
    let total = ways(0, amount)
    return (total, calls)
}

for amount in [20, 50, 100] {
    print("amount \(amount):", countWays(amount, memoise: false), countWays(amount, memoise: true))
}
