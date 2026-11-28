// Generated from src/dsa/content/lessons/dp-knapsack/dpk-count-subsets.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func countSubsets(_ numbers: [Int], target: Int) -> Int {
    var ways = Array(repeating: 0, count: target + 1)
    ways[0] = 1
    for x in numbers {
        for s in stride(from: target, through: x, by: -1) {   // for x = 0 this reaches s = 0 too
            ways[s] += ways[s - x]
        }
    }
    return ways[target]
}

/// Brute force: try every subset as a bitmask
func countByTrying(_ numbers: [Int], target: Int) -> Int {
    var count = 0
    for mask in 0..<(1 << numbers.count) {
        let sum = numbers.indices.filter { mask & (1 << $0) != 0 }.map { numbers[$0] }.reduce(0, +)
        if sum == target { count += 1 }
    }
    return count
}

print(countSubsets([0, 0, 1], target: 1), countByTrying([0, 0, 1], target: 1))
print(countSubsets([0, 0, 1], target: 0), countByTrying([0, 0, 1], target: 0))
print(countSubsets([3, 0, 2, 1], target: 3), countByTrying([3, 0, 2, 1], target: 3))
