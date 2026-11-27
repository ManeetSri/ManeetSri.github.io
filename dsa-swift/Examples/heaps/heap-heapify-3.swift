// Generated from src/dsa/content/lessons/heaps/heap-heapify.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Swaps to build a min-heap from values in decreasing order: n inserts against bottom-up heapify
func insertAll(_ values: [Int]) -> Int {
    var heap: [Int] = []
    var swaps = 0
    for value in values {
        heap.append(value)
        var child = heap.count - 1
        while child > 0 && heap[child] < heap[(child - 1) / 2] {
            heap.swapAt(child, (child - 1) / 2)
            child = (child - 1) / 2
            swaps += 1
        }
    }
    return swaps
}

func heapify(_ values: [Int]) -> Int {
    var items = values
    var swaps = 0
    for index in stride(from: items.count / 2 - 1, through: 0, by: -1) {
        var parent = index
        while true {
            let left = 2 * parent + 1
            let right = left + 1
            var smaller = parent
            if left < items.count && items[left] < items[smaller] { smaller = left }
            if right < items.count && items[right] < items[smaller] { smaller = right }
            if smaller == parent { break }
            items.swapAt(parent, smaller)
            parent = smaller
            swaps += 1
        }
    }
    return swaps
}

for n in [1_000, 10_000, 100_000] {
    let values = Array((1...n).reversed())
    print("n = \(n): inserts \(insertAll(values)) swaps, heapify \(heapify(values)) swaps")
}
