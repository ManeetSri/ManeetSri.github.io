// Generated from src/dsa/content/lessons/dp-knapsack/dpk-two-capacities.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// One string, "11": it costs 0 zeros and 2 ones. Budget: 2 zeros and 4 ones. It can be chosen once.
let a = 0
let b = 2
let zeros = 2
let ones = 4

func choose(onesDownward: Bool) -> Int {
    var best = Array(repeating: Array(repeating: 0, count: ones + 1), count: zeros + 1)
    for z in stride(from: zeros, through: a, by: -1) {
        let columns = onesDownward ? Array(stride(from: ones, through: b, by: -1)) : Array(stride(from: b, through: ones, by: 1))
        for o in columns {
            best[z][o] = max(best[z][o], best[z - a][o - b] + 1)   // z - a is z itself: the same row
        }
    }
    return best[zeros][ones]
}

print("both downward:      ", choose(onesDownward: true))
print("ones going upward:  ", choose(onesDownward: false))
