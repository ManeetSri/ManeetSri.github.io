// Generated from src/dsa/content/lessons/heaps/heap-heapify.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func siftDown(_ items: inout [Int], from index: Int) {
    var parent = index
    while true {
        let left = 2 * parent + 1
        let right = left + 1
        var smaller = parent
        if left < items.count && items[left] < items[smaller] { smaller = left }
        if right < items.count && items[right] < items[smaller] { smaller = right }
        if smaller == parent { return }
        items.swapAt(parent, smaller)
        parent = smaller
    }
}

var items = [9, 4, 7, 1, 8, 2, 6, 3, 5]
for index in stride(from: items.count / 2 - 1, through: 0, by: -1) {
    siftDown(&items, from: index)
    print("after sifting down index \(index): \(items)")
}
