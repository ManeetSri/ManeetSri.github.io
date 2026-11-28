// Generated from src/dsa/content/lessons/heaps/heap-sort.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Heap sort on items[low...high] only: heap index i lives at items[low + i]
func heapSort(_ items: inout [Int], _ low: Int, _ high: Int) {
    let count = high - low + 1
    func siftDown(from index: Int, end: Int) {
        var parent = index
        while true {
            let left = 2 * parent + 1
            let right = left + 1
            var largest = parent
            if left < end && items[low + left] > items[low + largest] { largest = left }
            if right < end && items[low + right] > items[low + largest] { largest = right }
            if largest == parent { return }
            items.swapAt(low + parent, low + largest)
            parent = largest
        }
    }
    for index in stride(from: count / 2 - 1, through: 0, by: -1) {
        siftDown(from: index, end: count)
    }
    var end = count - 1
    while end > 0 {
        items.swapAt(low, low + end)
        siftDown(from: 0, end: end)
        end -= 1
    }
}

var items = [99, 98, 7, 3, 9, 1, 5, 0, -1]
heapSort(&items, 2, 6)              // sorts only indexes 2 to 6
print(items)
