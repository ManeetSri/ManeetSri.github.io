// Generated from src/dsa/content/lessons/backtracking/bk-subsets.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func subsetsByNextItem(_ items: [Int]) -> [[Int]] {
    var chosen: [Int] = []
    var result: [[Int]] = []

    func explore(from start: Int) {
        result.append(chosen)                    // every node is an answer
        for i in start..<items.count {
            chosen.append(items[i])              // choose items[i] as the next item
            explore(from: i + 1)                 // only items to its right after it
            chosen.removeLast()                  // unchoose
        }
    }

    explore(from: 0)
    return result
}

print(subsetsByNextItem([1, 2, 3]))
