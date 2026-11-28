// Generated from src/dsa/content/lessons/dp-knapsack/dpk-last-stone.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// The lightest stone that can be left: the total minus twice the heaviest pile that's at most half
func smallestLeftover(_ stones: [Int]) -> Int {
    let total = stones.reduce(0, +)
    let half = total / 2
    var reachable = Array(repeating: false, count: half + 1)
    reachable[0] = true
    for stone in stones where stone <= half {
        for s in stride(from: half, through: stone, by: -1) where reachable[s - stone] {
            reachable[s] = true
        }
    }
    let lighterPile = (0...half).last { reachable[$0] }!     // reachable[0] is true, so there is one
    return total - 2 * lighterPile
}

print(smallestLeftover([8, 3, 12, 5, 9]))
print(smallestLeftover([6, 2, 9, 4, 3]))
print(smallestLeftover([1, 2, 4, 8, 16]))
print(smallestLeftover([7]))
