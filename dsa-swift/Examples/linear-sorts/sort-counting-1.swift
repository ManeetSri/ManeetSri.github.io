// Generated from src/dsa/content/lessons/linear-sorts/sort-counting.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func countingSort(_ items: [Int], maxValue: Int) -> [Int] {
    var counts = [Int](repeating: 0, count: maxValue + 1)
    for value in items {
        counts[value] += 1
    }
    print("counts:", counts)
    var sorted: [Int] = []
    for value in 0...maxValue {
        sorted += Array(repeating: value, count: counts[value])
    }
    return sorted
}

print(countingSort([4, 2, 2, 8, 3, 3, 1], maxValue: 8))
