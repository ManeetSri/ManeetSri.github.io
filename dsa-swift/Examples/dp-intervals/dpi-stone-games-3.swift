// Generated from src/dsa/content/lessons/dp-intervals/dpi-stone-games.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func takeOneToThree(_ coins: [Int]) -> Int {
    let n = coins.count
    var best = Array(repeating: 0, count: n + 1)          // best[n]: no coins left, margin 0
    for i in stride(from: n - 1, through: 0, by: -1) {
        best[i] = Int.min
        var taken = 0
        for t in 1...3 where i + t <= n {
            taken += coins[i + t - 1]
            best[i] = max(best[i], taken - best[i + t])   // take t coins, then the opponent moves
        }
    }
    return best[0]
}

print(takeOneToThree([5, -3, 8, 1, 1]))
print(takeOneToThree([2, 4, -1, 6]))
