// Generated from src/dsa/content/lessons/heaps/heap-sort.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// Sifts items[index] down a max-heap that occupies items[0..<end]
func siftDown(_ items: inout [Int], from index: Int, end: Int) {
    var parent = index
    while true {
        let left = 2 * parent + 1
        let right = left + 1
        var largest = parent
        if left < end && items[left] > items[largest] { largest = left }
        if right < end && items[right] > items[largest] { largest = right }
        if largest == parent { return }
        items.swapAt(parent, largest)
        parent = largest
    }
}

func heapSort(_ items: inout [Int]) {
    for index in stride(from: items.count / 2 - 1, through: 0, by: -1) {
        siftDown(&items, from: index, end: items.count)
    }
    print("max-heap:", items)
    var end = items.count - 1
    while end > 0 {
        items.swapAt(0, end)                     // the largest joins the sorted part
        siftDown(&items, from: 0, end: end)      // repair the smaller heap
        print("heap \(Array(items[..<end])) | sorted \(Array(items[end...]))")
        end -= 1
    }
}

var numbers = [5, 2, 9, 1, 6, 3]
heapSort(&numbers)
print(numbers)
