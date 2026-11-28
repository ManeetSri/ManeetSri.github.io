// Generated from src/dsa/content/lessons/dp-knapsack/dpk-subset-sum.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// Can `numbers` (all positive) be split into two groups with equal sums?
func canSplitEvenly(_ numbers: [Int]) -> Bool {
    let total = numbers.reduce(0, +)
    if total % 2 != 0 { return false }                   // an odd total can't be halved
    let half = total / 2
    if numbers.contains(where: { $0 > half }) { return false }   // one number outweighs the rest
    var reachable = Array(repeating: false, count: half + 1)
    reachable[0] = true
    for x in numbers {
        for s in stride(from: half, through: x, by: -1) where reachable[s - x] {
            reachable[s] = true
        }
        if reachable[half] { return true }               // one group found; the rest is the other
    }
    return false
}

print(canSplitEvenly([4, 7, 2, 5, 6]))      // total 24: 4 + 2 + 6 = 12 = 7 + 5
print(canSplitEvenly([3, 5, 9, 4, 1]))      // total 22, but nothing makes 11
print(canSplitEvenly([2, 3, 4]))            // total 9 is odd
print(canSplitEvenly([1, 2, 9]))            // 9 is more than half of 12
