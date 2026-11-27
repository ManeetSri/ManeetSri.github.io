// Generated from src/dsa/content/lessons/heaps/heap-sift.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var heap = [1, 3, 2, 5, 9, 8]

func pop() -> Int? {
    guard !heap.isEmpty else { return nil }
    heap.swapAt(0, heap.count - 1)
    let smallest = heap.removeLast()
    var parent = 0
    while true {
        let left = 2 * parent + 1
        let right = left + 1
        var smaller = parent                          // the smallest of parent and its children
        if left < heap.count && heap[left] < heap[smaller] { smaller = left }
        if right < heap.count && heap[right] < heap[smaller] { smaller = right }
        if smaller == parent { break }                // settled: no child is smaller
        heap.swapAt(parent, smaller)
        parent = smaller
    }
    return smallest
}

while let smallest = pop() {
    print("pop \(smallest): \(heap)")
}
