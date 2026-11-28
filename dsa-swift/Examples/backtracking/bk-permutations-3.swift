// Generated from src/dsa/content/lessons/backtracking/bk-permutations.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func distinctPermutations(_ items: [Int]) -> [[Int]] {
    let sorted = items.sorted()
    var used = Array(repeating: false, count: sorted.count)
    var current: [Int] = []
    var result: [[Int]] = []

    func explore() {
        if current.count == sorted.count {
            result.append(current)
            return
        }
        for i in sorted.indices where !used[i] {
            // Equal values are used left to right: skip a copy while the one before it is still free
            if i > 0 && sorted[i] == sorted[i - 1] && !used[i - 1] { continue }
            used[i] = true
            current.append(sorted[i])
            explore()
            current.removeLast()
            used[i] = false
        }
    }

    explore()
    return result
}

print(distinctPermutations([1, 2, 1]))
print(distinctPermutations([2, 2, 2]).count, distinctPermutations([1, 1, 2, 2]).count)
