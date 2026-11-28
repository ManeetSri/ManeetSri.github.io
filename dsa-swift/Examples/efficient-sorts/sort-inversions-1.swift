// Generated from src/dsa/content/lessons/efficient-sorts/sort-inversions.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func inversions(_ numbers: [Int]) -> [(Int, Int)] {
    var pairs: [(Int, Int)] = []
    for i in numbers.indices {
        for j in (i + 1)..<numbers.count where numbers[i] > numbers[j] {
            pairs.append((numbers[i], numbers[j]))
        }
    }
    return pairs
}

for numbers in [[2, 4, 1, 3, 5], [1, 2, 3, 4], [4, 3, 2, 1], [3, 1, 3, 2]] {
    let pairs = inversions(numbers)
    let shown = pairs.map { "(\($0.0), \($0.1))" }.joined(separator: " ")
    print(numbers, pairs.count, shown.isEmpty ? "none" : shown)
}
