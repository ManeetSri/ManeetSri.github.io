// Generated from src/dsa/content/lessons/heaps/heap-sift.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var heap: [Int] = []

func push(_ value: Int) {
    heap.append(value)
    var child = heap.count - 1
    while child > 0 {
        let parent = (child - 1) / 2
        if heap[child] >= heap[parent] { break }      // settled: no smaller than its parent
        heap.swapAt(child, parent)
        child = parent
    }
}

for value in [5, 3, 8, 1, 9, 2] {
    push(value)
    print("push \(value): \(heap)")
}
