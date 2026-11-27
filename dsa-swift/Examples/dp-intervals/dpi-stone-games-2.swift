// Generated from src/dsa/content/lessons/dp-intervals/dpi-stone-games.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func bestMargin(_ coins: [Int]) -> Int {
    let n = coins.count
    guard n > 0 else { return 0 }
    var margin = Array(repeating: Array(repeating: 0, count: n), count: n)
    for i in stride(from: n - 1, through: 0, by: -1) {
        margin[i][i] = coins[i]                               // one coin left: take it
        for j in stride(from: i + 1, to: n, by: 1) {
            let takeLeft = coins[i] - margin[i + 1][j]        // the opponent then moves on i+1...j
            let takeRight = coins[j] - margin[i][j - 1]       // or on i...j-1
            margin[i][j] = max(takeLeft, takeRight)
        }
    }
    for row in margin {
        print(row)
    }
    return margin[0][n - 1]
}

let coins = [3, 9, 1, 2]
let margin = bestMargin(coins)
let total = coins.reduce(0, +)
print("margin:", margin, "first player:", (total + margin) / 2, "second player:", (total - margin) / 2)
