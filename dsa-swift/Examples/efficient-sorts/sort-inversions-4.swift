// Generated from src/dsa/content/lessons/efficient-sorts/sort-inversions.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Count inversions while merge sorting, and show each merge's "across" count
func sortAndCount(_ items: inout [Int], _ buffer: inout [Int], _ low: Int, _ high: Int) -> Int {
    guard high - low > 1 else { return 0 }
    let mid = low + (high - low) / 2
    var inversions = sortAndCount(&items, &buffer, low, mid) + sortAndCount(&items, &buffer, mid, high)
    for index in low..<high {
        buffer[index] = items[index]
    }
    var across = 0
    var left = low
    var right = mid
    for write in low..<high {
        if right == high || (left < mid && buffer[left] <= buffer[right]) {
            items[write] = buffer[left]
            left += 1
        } else {
            items[write] = buffer[right]
            right += 1
            across += mid - left             // it jumps ahead of everything left in the left half
        }
    }
    print("merge \(Array(buffer[low..<mid])) + \(Array(buffer[mid..<high])): \(across) across")
    inversions += across
    return inversions
}

func countInversions(_ numbers: [Int]) -> Int {
    var items = numbers
    var buffer = numbers
    return sortAndCount(&items, &buffer, 0, items.count)
}

print("total:", countInversions([5, 2, 6, 1, 3, 4]))
