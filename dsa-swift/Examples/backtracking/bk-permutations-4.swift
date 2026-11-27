// Generated from src/dsa/content/lessons/backtracking/bk-permutations.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func distinctPermutationsByCount(_ items: [Int]) -> [[Int]] {
    var remaining: [Int: Int] = [:]
    for item in items {
        remaining[item, default: 0] += 1
    }
    let values = remaining.keys.sorted()         // each distinct value once, in order
    var current: [Int] = []
    var result: [[Int]] = []

    func explore() {
        if current.count == items.count {
            result.append(current)
            return
        }
        for value in values where remaining[value]! > 0 {
            remaining[value]! -= 1               // choose one copy of value
            current.append(value)
            explore()
            current.removeLast()
            remaining[value]! += 1               // put it back
        }
    }

    explore()
    return result
}

print(distinctPermutationsByCount([3, 1, 3, 3]))
