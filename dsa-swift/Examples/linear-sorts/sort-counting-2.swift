// Generated from src/dsa/content/lessons/linear-sorts/sort-counting.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func countingSort(_ items: [Int]) -> [Int] {
    guard let low = items.min(), let high = items.max() else { return [] }
    var counts = [Int](repeating: 0, count: high - low + 1)
    for value in items {
        counts[value - low] += 1                 // the smallest value goes in slot 0
    }
    var sorted: [Int] = []
    sorted.reserveCapacity(items.count)
    for (offset, times) in counts.enumerated() {
        sorted += Array(repeating: low + offset, count: times)
    }
    return sorted
}

let overnightLows = [3, -2, 0, -2, 5, 1]
print(countingSort(overnightLows))
print(countingSort([]))
