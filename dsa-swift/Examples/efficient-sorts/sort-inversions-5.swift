// Generated from src/dsa/content/lessons/efficient-sorts/sort-inversions.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Operations to count inversions: every pair vs merge sort
func bruteForceComparisons(_ n: Int) -> Int {
    n * (n - 1) / 2                          // the loops check every pair once
}

func mergeComparisons(_ numbers: [Int]) -> Int {
    var items = numbers
    var buffer = numbers
    var comparisons = 0
    func sortRange(_ low: Int, _ high: Int) {
        guard high - low > 1 else { return }
        let mid = low + (high - low) / 2
        sortRange(low, mid)
        sortRange(mid, high)
        for index in low..<high { buffer[index] = items[index] }
        var left = low
        var right = mid
        for write in low..<high {
            if right < high && left < mid { comparisons += 1 }
            if right == high || (left < mid && buffer[left] <= buffer[right]) {
                items[write] = buffer[left]
                left += 1
            } else {
                items[write] = buffer[right]
                right += 1
            }
        }
    }
    sortRange(0, items.count)
    return comparisons
}

for n in [1_000, 10_000, 100_000] {
    let mixed = (0..<n).map { ($0 * 7_919) % n }
    print("n = \(n): every pair \(bruteForceComparisons(n)), merge sort \(mergeComparisons(mixed))")
}
