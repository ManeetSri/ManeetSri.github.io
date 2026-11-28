// Generated from src/dsa/content/lessons/backtracking/bk-permutations.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func permutationsBySwapping(_ items: [Int]) -> [[Int]] {
    var items = items                            // a mutable copy: parameters are constants
    var result: [[Int]] = []

    func explore(_ k: Int) {                     // positions 0..<k are fixed
        if k == items.count {
            result.append(items)
            return
        }
        for i in k..<items.count {
            items.swapAt(k, i)                   // choose items[i] for position k
            explore(k + 1)
            items.swapAt(k, i)                   // unchoose: swap it back
        }
    }

    explore(0)
    return result
}

print(permutationsBySwapping([1, 2, 3]))
