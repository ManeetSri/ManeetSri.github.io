// Generated from src/dsa/content/lessons/efficient-sorts/sort-merge.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Merge sort on index ranges of one array, with one buffer shared by every merge
func mergeSort(_ items: inout [Int]) {
    var buffer = items                       // made once, the same size as items
    sortRange(&items, &buffer, 0, items.count)
}

/// Sorts items[low..<high]
func sortRange(_ items: inout [Int], _ buffer: inout [Int], _ low: Int, _ high: Int) {
    guard high - low > 1 else { return }
    let mid = low + (high - low) / 2
    sortRange(&items, &buffer, low, mid)
    sortRange(&items, &buffer, mid, high)

    // Copy the two sorted halves into the buffer, then merge them back into items
    for index in low..<high {
        buffer[index] = items[index]
    }
    var left = low
    var right = mid
    for write in low..<high {
        if right == high || (left < mid && buffer[left] <= buffer[right]) {
            items[write] = buffer[left]
            left += 1
        } else {
            items[write] = buffer[right]
            right += 1
        }
    }
}

var numbers = [38, 27, 43, 3, 9, 82, 10]
mergeSort(&numbers)
print(numbers)

var empty: [Int] = []
mergeSort(&empty)
print(empty)
