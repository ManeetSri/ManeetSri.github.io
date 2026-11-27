// Generated from src/dsa/content/lessons/greedy/greedy-idea.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Pay `amount` with as few coins as possible: biggest coin that fits, every time
func greedyChange(_ amount: Int, coins: [Int]) -> [Int] {
    var left = amount
    var used: [Int] = []
    for coin in coins.sorted(by: >) {     // biggest first
        while coin <= left {
            used.append(coin)
            left -= coin
        }
    }
    return used
}

let euroCents = [1, 2, 5, 10, 20, 50]
print(greedyChange(68, coins: euroCents))
print(greedyChange(99, coins: euroCents))
print(greedyChange(40, coins: euroCents))
