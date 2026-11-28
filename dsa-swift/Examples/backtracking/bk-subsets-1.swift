// Generated from src/dsa/content/lessons/backtracking/bk-subsets.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func subsetsInOrOut(_ items: [Int]) -> [[Int]] {
    var chosen: [Int] = []
    var result: [[Int]] = []

    func explore(_ index: Int) {
        if index == items.count {                // every item decided
            result.append(chosen)
            return
        }
        chosen.append(items[index])              // in
        explore(index + 1)
        chosen.removeLast()                      // back out of "in"
        explore(index + 1)                       // out
    }

    explore(0)
    return result
}

print(subsetsInOrOut([1, 2, 3]))
