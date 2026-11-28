// Generated from src/dsa/content/lessons/backtracking/bk-combinations.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func combinationSum(_ candidates: [Int], _ target: Int) -> [[Int]] {
    let sorted = candidates.sorted()
    var chosen: [Int] = []
    var result: [[Int]] = []

    func explore(from start: Int, remaining: Int) {
        if remaining == 0 {
            result.append(chosen)
            return
        }
        for i in start..<sorted.count {
            if sorted[i] > remaining { break }                  // sorted: the rest are too big as well
            chosen.append(sorted[i])
            explore(from: i, remaining: remaining - sorted[i])  // i, not i + 1: it may be used again
            chosen.removeLast()
        }
    }

    explore(from: 0, remaining: target)
    return result
}

print(combinationSum([5, 2, 3], 8))
print(combinationSum([4, 6], 9))
