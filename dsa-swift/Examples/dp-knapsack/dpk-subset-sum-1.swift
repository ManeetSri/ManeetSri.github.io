// Generated from src/dsa/content/lessons/dp-knapsack/dpk-subset-sum.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// reachable[s] is true when some of `numbers`, each used at most once, add up to exactly s
func reachableSums(_ numbers: [Int], upTo limit: Int) -> [Bool] {
    var reachable = Array(repeating: false, count: limit + 1)
    reachable[0] = true                                  // the empty subset makes 0
    for x in numbers {
        // Right to left, so reachable[s - x] still means "without x"
        for s in stride(from: limit, through: x, by: -1) where reachable[s - x] {
            reachable[s] = true
        }
        print("after \(x):", (0...limit).filter { reachable[$0] })
    }
    return reachable
}

let reachable = reachableSums([3, 5, 9, 4], upTo: 13)
print("12?", reachable[12], " 11?", reachable[11])
