// Generated from src/dsa/content/lessons/dp-knapsack/dpk-count-subsets.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// How many subsets of `numbers` (each used at most once) add up to each sum from 0 to target?
func subsetCounts(_ numbers: [Int], target: Int) -> [Int] {
    var ways = Array(repeating: 0, count: target + 1)
    ways[0] = 1                                          // one way to make 0: take nothing
    for x in numbers {
        for s in stride(from: target, through: x, by: -1) {
            ways[s] += ways[s - x]                       // every way to make s - x, plus x
        }
        print("after \(x):", ways)
    }
    return ways
}

let ways = subsetCounts([2, 3, 5, 1], target: 6)
print("subsets adding up to 6:", ways[6])
