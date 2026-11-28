// Generated from src/dsa/content/lessons/backtracking/bk-combinations.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func combinations(_ items: [Int], choose k: Int, pruned: Bool) -> (result: [[Int]], nodes: Int) {
    var chosen: [Int] = []
    var result: [[Int]] = []
    var nodes = 0

    func explore(from start: Int) {
        nodes += 1
        if chosen.count == k {
            result.append(chosen)
            return
        }
        for i in start..<items.count {
            // Not enough items left to reach k? Then no later i can either.
            if pruned && items.count - i < k - chosen.count { break }
            chosen.append(items[i])
            explore(from: i + 1)
            chosen.removeLast()
        }
    }

    explore(from: 0)
    return (result, nodes)
}

print(combinations([1, 2, 3, 4], choose: 2, pruned: true).result)
let digits = Array(1...10)
let plain = combinations(digits, choose: 7, pruned: false)
let cut = combinations(digits, choose: 7, pruned: true)
print("7 of 10:", plain.result.count, "combinations,", plain.nodes, "nodes without pruning,", cut.nodes, "with")
