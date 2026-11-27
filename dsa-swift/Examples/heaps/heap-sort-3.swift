// Generated from src/dsa/content/lessons/heaps/heap-sort.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Heap sort by a key, compared with Swift's stable sorted(by:)
func heapSort<T>(_ items: inout [T], by key: (T) -> Int) {
    func siftDown(from index: Int, end: Int) {
        var parent = index
        while true {
            let left = 2 * parent + 1
            let right = left + 1
            var largest = parent
            if left < end && key(items[left]) > key(items[largest]) { largest = left }
            if right < end && key(items[right]) > key(items[largest]) { largest = right }
            if largest == parent { return }
            items.swapAt(parent, largest)
            parent = largest
        }
    }
    for index in stride(from: items.count / 2 - 1, through: 0, by: -1) {
        siftDown(from: index, end: items.count)
    }
    var end = items.count - 1
    while end > 0 {
        items.swapAt(0, end)
        siftDown(from: 0, end: end)
        end -= 1
    }
}

let orders = [(total: 20, id: "A"), (total: 10, id: "B"), (total: 20, id: "C"), (total: 20, id: "D")]
var heapSorted = orders
heapSort(&heapSorted, by: { $0.total })
print("heap sort:  ", heapSorted.map { "\($0.total)\($0.id)" })
print("sorted(by:):", orders.sorted { $0.total < $1.total }.map { "\($0.total)\($0.id)" })
