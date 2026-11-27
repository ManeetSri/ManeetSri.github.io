// Generated from src/dsa/content/lessons/backtracking/bk-combinations.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func combinationSumOnce(_ candidates: [Int], _ target: Int) -> [[Int]] {
    let sorted = candidates.sorted()
    var chosen: [Int] = []
    var result: [[Int]] = []

    func explore(from start: Int, remaining: Int) {
        if remaining == 0 {
            result.append(chosen)
            return
        }
        for i in start..<sorted.count {
            if i > start && sorted[i] == sorted[i - 1] { continue }   // equal sibling: same subtree
            if sorted[i] > remaining { break }
            chosen.append(sorted[i])
            explore(from: i + 1, remaining: remaining - sorted[i])    // i + 1: each item once
            chosen.removeLast()
        }
    }

    explore(from: 0, remaining: target)
    return result
}

print(combinationSumOnce([4, 1, 2, 4, 3, 1], 6))
