// Generated from src/dsa/content/lessons/patterns/pat-templates-paradigms.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Backtracking, three shapes: a start index, a used array, and skipping duplicates

// Combinations that add up to target, each candidate reusable (start index, pruning by sorting)
func combinationSum(_ candidates: [Int], _ target: Int) -> [[Int]] {
    let sorted = candidates.sorted()
    var result: [[Int]] = []
    var chosen: [Int] = []
    func explore(_ start: Int, _ remaining: Int) {
        if remaining == 0 {
            result.append(chosen)                 // a copy: Swift arrays are values
            return
        }
        for i in start..<sorted.count {
            if sorted[i] > remaining { break }    // sorted, so every later candidate is too big
            chosen.append(sorted[i])              // choose
            explore(i, remaining - sorted[i])     // explore: i, not i + 1, allows reuse
            chosen.removeLast()                   // unchoose
        }
    }
    explore(0, target)
    return result
}

// Every ordering (a used array, because any unused item can come next)
func permutations(_ items: [Int]) -> [[Int]] {
    var result: [[Int]] = []
    var chosen: [Int] = []
    var used = Array(repeating: false, count: items.count)
    func explore() {
        if chosen.count == items.count {
            result.append(chosen)
            return
        }
        for i in items.indices where !used[i] {
            used[i] = true
            chosen.append(items[i])
            explore()
            chosen.removeLast()
            used[i] = false
        }
    }
    explore()
    return result
}

// Subsets when the items repeat: sort, then never start a branch with the same value twice at one level
func distinctSubsets(_ items: [Int]) -> [[Int]] {
    let sorted = items.sorted()
    var result: [[Int]] = []
    var chosen: [Int] = []
    func explore(_ start: Int) {
        result.append(chosen)
        for i in start..<sorted.count {
            if i > start && sorted[i] == sorted[i - 1] { continue }   // same choice as the last branch
            chosen.append(sorted[i])
            explore(i + 1)
            chosen.removeLast()
        }
    }
    explore(0)
    return result
}

print(combinationSum([5, 2, 3], 8))
print(permutations([1, 2, 3]).count, permutations([1, 2, 3]).last!)
print(distinctSubsets([2, 1, 2]))
