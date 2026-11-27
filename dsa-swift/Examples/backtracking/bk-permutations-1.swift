// Generated from src/dsa/content/lessons/backtracking/bk-permutations.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func permutations(_ items: [Int]) -> [[Int]] {
    var used = Array(repeating: false, count: items.count)
    var current: [Int] = []
    var result: [[Int]] = []

    func explore() {
        if current.count == items.count {        // every position filled
            result.append(current)
            return
        }
        for i in items.indices where !used[i] {
            used[i] = true                       // choose
            current.append(items[i])
            explore()                            // explore
            current.removeLast()                 // unchoose: both changes undone
            used[i] = false
        }
    }

    explore()
    return result
}

print(permutations([1, 2, 3]))
