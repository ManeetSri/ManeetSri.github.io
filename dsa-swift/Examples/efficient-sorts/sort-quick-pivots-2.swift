// Generated from src/dsa/content/lessons/efficient-sorts/sort-quick-pivots.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var comparisons = 0

/// The index of the median of items[low], items[mid] and items[high]
func medianOfThree(_ items: [Int], _ low: Int, _ high: Int) -> Int {
    let mid = low + (high - low) / 2
    let a = items[low], b = items[mid], c = items[high]
    if (a <= b) == (b <= c) { return mid }    // b is between a and c
    if (b <= a) == (a <= c) { return low }    // a is between b and c
    return high
}

func partition(_ items: inout [Int], _ low: Int, _ high: Int, pivotIndex: Int) -> Int {
    items.swapAt(pivotIndex, high)
    let pivot = items[high]
    var boundary = low
    for j in low..<high {
        comparisons += 1
        if items[j] < pivot {
            items.swapAt(boundary, j)
            boundary += 1
        }
    }
    items.swapAt(boundary, high)
    return boundary
}

func quickSort(_ items: inout [Int], _ low: Int, _ high: Int) {
    guard low < high else { return }
    let p = partition(&items, low, high, pivotIndex: medianOfThree(items, low, high))
    quickSort(&items, low, p - 1)
    quickSort(&items, p + 1, high)
}

print(medianOfThree([5, 9, 1], 0, 2), medianOfThree([1, 5, 9], 0, 2), medianOfThree([9, 1, 5], 0, 2))

let n = 2_000
for (name, input) in [("sorted", Array(0..<n)), ("reversed", Array((0..<n).reversed())), ("mixed", (0..<n).map { ($0 * 7_919) % n })] {
    var items = input
    comparisons = 0
    quickSort(&items, 0, n - 1)
    print("\(name): \(comparisons) comparisons")
}
