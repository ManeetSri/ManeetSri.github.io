// Generated from src/dsa/content/lessons/backtracking/bk-subsets.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func subsetsWithRepeats(_ items: [Int]) -> [[Int]] {
    let sorted = items.sorted()                  // equal values side by side
    var chosen: [Int] = []
    var result: [[Int]] = []

    func explore(from start: Int) {
        result.append(chosen)
        for i in start..<sorted.count {
            if i > start && sorted[i] == sorted[i - 1] { continue }   // equal sibling: same subtree again
            chosen.append(sorted[i])
            explore(from: i + 1)
            chosen.removeLast()
        }
    }

    explore(from: 0)
    return result
}

print(subsetsWithRepeats([2, 1, 2]))
print(subsetsWithRepeats([3, 3, 3]))
