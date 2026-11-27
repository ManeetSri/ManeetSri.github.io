// Generated from src/dsa/content/lessons/dp-knapsack/dpk-count-subsets.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func countSubsets(_ numbers: [Int], target: Int) -> Int {
    var ways = Array(repeating: 0, count: target + 1)
    ways[0] = 1
    for x in numbers {
        for s in stride(from: target, through: x, by: -1) {
            ways[s] += ways[s - x]
        }
    }
    return ways[target]
}

/// Ways to put + or - in front of every number so the expression equals target
func signWays(_ numbers: [Int], target: Int) -> Int {
    let total = numbers.reduce(0, +)
    // plus - minus = target and plus + minus = total, so plus = (total + target) / 2
    if abs(target) > total || (total + target) % 2 != 0 { return 0 }
    return countSubsets(numbers, target: (total + target) / 2)
}

/// Brute force: bit i of the mask set means numbers[i] gets a plus sign
func signWaysByTrying(_ numbers: [Int], target: Int) -> Int {
    var count = 0
    for mask in 0..<(1 << numbers.count) {
        var value = 0
        for i in numbers.indices {
            value += mask & (1 << i) != 0 ? numbers[i] : -numbers[i]
        }
        if value == target { count += 1 }
    }
    return count
}

let numbers = [1, 1, 2, 3]
for target in [1, 3, -3, 7, 2] {
    print("target \(target): DP \(signWays(numbers, target: target)), brute force \(signWaysByTrying(numbers, target: target))")
}
