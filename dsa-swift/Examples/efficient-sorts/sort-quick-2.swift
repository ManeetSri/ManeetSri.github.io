// Generated from src/dsa/content/lessons/efficient-sorts/sort-quick.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func lomutoPartition(_ items: inout [Int], _ low: Int, _ high: Int) -> Int {
    let pivot = items[high]
    var boundary = low
    for j in low..<high where items[j] < pivot {
        items.swapAt(boundary, j)
        boundary += 1
    }
    items.swapAt(boundary, high)
    return boundary
}

/// Sorts items[low...high], a closed range
func quickSort(_ items: inout [Int], _ low: Int, _ high: Int, depth: Int = 0) {
    guard low < high else { return }         // 0 or 1 elements
    let p = lomutoPartition(&items, low, high)
    let indent = String(repeating: "  ", count: depth)
    print("\(indent)\(low)...\(high) around \(items[p]): \(items[low...high])")
    quickSort(&items, low, p - 1, depth: depth + 1)
    quickSort(&items, p + 1, high, depth: depth + 1)
}

var numbers = [7, 2, 9, 4, 3, 8, 5]
quickSort(&numbers, 0, numbers.count - 1)
print(numbers)
