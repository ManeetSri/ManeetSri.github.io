// Generated from src/dsa/content/lessons/dp-advanced/dpa-optimisations.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Split numbers (in order) into exactly k non-empty groups; a group with sum s costs s². Minimise the total.
// layer g: best[g][i] = min over j < i of best[g - 1][j] + (S[i] - S[j])², for the first i numbers
func splitCost(_ numbers: [Int], groups k: Int, divideAndConquer: Bool) -> (cost: Int, steps: Int) {
    let n = numbers.count
    var prefix = [0]
    for x in numbers { prefix.append(prefix.last! + x) }
    func groupCost(_ j: Int, _ i: Int) -> Int {       // numbers j..<i as one group
        let s = prefix[i] - prefix[j]
        return s * s
    }
    let unreached = Int.max / 2
    var previous = (0...n).map { $0 == 0 ? 0 : unreached }   // zero groups: only "nothing" is possible
    var steps = 0
    for _ in 1...k {
        var current = [Int](repeating: unreached, count: n + 1)
        // Fill current[i] for i in lo...hi, knowing the best j lies in optLo...optHi
        func solve(_ lo: Int, _ hi: Int, _ optLo: Int, _ optHi: Int) {
            if lo > hi { return }
            let mid = (lo + hi) / 2
            var bestJ = optLo
            for j in optLo...min(mid - 1, optHi) where previous[j] < unreached {
                steps += 1
                let candidate = previous[j] + groupCost(j, mid)
                if candidate < current[mid] {
                    current[mid] = candidate
                    bestJ = j
                }
            }
            solve(lo, mid - 1, optLo, bestJ)          // to the left, the best j is no later
            solve(mid + 1, hi, bestJ, optHi)          // to the right, it's no earlier
        }
        if divideAndConquer {
            solve(1, n, 0, n - 1)
        } else {
            for i in 1...n {
                for j in 0..<i where previous[j] < unreached {
                    steps += 1
                    current[i] = min(current[i], previous[j] + groupCost(j, i))
                }
            }
        }
        previous = current
    }
    return (previous[n], steps)
}

print(splitCost([3, 1, 4, 1, 5, 9, 2, 6], groups: 3, divideAndConquer: false).cost,
      splitCost([3, 1, 4, 1, 5, 9, 2, 6], groups: 3, divideAndConquer: true).cost)
let numbers = (0..<600).map { ($0 * $0 * 7 + $0 * 13 + 5) % 97 + 1 }
let plain = splitCost(numbers, groups: 6, divideAndConquer: false)
let fast = splitCost(numbers, groups: 6, divideAndConquer: true)
print(plain.cost, fast.cost)
print("candidates tried:", plain.steps, "vs", fast.steps)
