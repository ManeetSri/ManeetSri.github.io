// Generated from src/dsa/content/lessons/dp-knapsack/dpk-count-subsets.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let mod = 1_000_000_007

/// Subsets adding up to target, counted modulo 1,000,000,007
func countSubsets(_ numbers: [Int], target: Int) -> Int {
    var ways = Array(repeating: 0, count: target + 1)
    ways[0] = 1
    for x in numbers {
        for s in stride(from: target, through: x, by: -1) {
            ways[s] = (ways[s] + ways[s - x]) % mod      // both are below mod, so the sum fits easily
        }
    }
    return ways[target]
}

let hundredOnes = Array(repeating: 1, count: 100)
print(countSubsets(hundredOnes, target: 50))             // C(100, 50), about 1.0 × 10²⁹, reduced
print(countSubsets(Array(repeating: 1, count: 20), target: 10))   // C(20, 10) is small enough to see whole
