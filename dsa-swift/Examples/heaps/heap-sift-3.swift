// Generated from src/dsa/content/lessons/heaps/heap-sift.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Count the swaps made by pushes and pops on a min-heap
var heap: [Int] = []
var swaps = 0

func push(_ value: Int) {
    heap.append(value)
    var child = heap.count - 1
    while child > 0 && heap[child] < heap[(child - 1) / 2] {
        heap.swapAt(child, (child - 1) / 2)
        child = (child - 1) / 2
        swaps += 1
    }
}

func pop() -> Int {
    heap.swapAt(0, heap.count - 1)
    let smallest = heap.removeLast()
    var parent = 0
    while true {
        let left = 2 * parent + 1
        let right = left + 1
        var smaller = parent
        if left < heap.count && heap[left] < heap[smaller] { smaller = left }
        if right < heap.count && heap[right] < heap[smaller] { smaller = right }
        if smaller == parent { return smallest }
        heap.swapAt(parent, smaller)
        parent = smaller
        swaps += 1
    }
}

let n = 100_000
for value in stride(from: n, to: 0, by: -1) {        // each new value is the smallest so far
    push(value)
}
print("\(n) pushes: \(swaps) swaps, \(swaps / n) per push on average")

swaps = 0
var inOrder = true
for expected in 1...n where pop() != expected {
    inOrder = false
}
print("\(n) pops: \(swaps) swaps, \(swaps / n) per pop on average, in order: \(inOrder)")
