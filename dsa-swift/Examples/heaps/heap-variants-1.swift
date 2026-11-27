// Generated from src/dsa/content/lessons/heaps/heap-variants.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// A min-heap where every node has up to d children, counting comparisons
struct DaryHeap {
    let d: Int
    var items: [Int] = []
    var comparisons = 0

    mutating func push(_ value: Int) {
        items.append(value)
        var child = items.count - 1
        while child > 0 {
            let parent = (child - 1) / d
            comparisons += 1
            if items[child] >= items[parent] { break }
            items.swapAt(child, parent)
            child = parent
        }
    }

    mutating func pop() -> Int? {
        guard !items.isEmpty else { return nil }
        items.swapAt(0, items.count - 1)
        let top = items.removeLast()
        var parent = 0
        while true {
            let firstChild = d * parent + 1
            if firstChild >= items.count { break }
            var smallest = firstChild                    // find the smallest of up to d children
            for child in (firstChild + 1)..<min(firstChild + d, items.count) {
                comparisons += 1
                if items[child] < items[smallest] { smallest = child }
            }
            comparisons += 1
            if items[smallest] >= items[parent] { break }
            items.swapAt(parent, smallest)
            parent = smallest
        }
        return top
    }
}

let n = 50_000
let values = Array((0..<n).reversed())             // each push is the smallest so far: the worst case
for d in [2, 4, 8, 16] {
    var heap = DaryHeap(d: d)
    for value in values {
        heap.push(value)
    }
    let pushComparisons = heap.comparisons
    heap.comparisons = 0
    var inOrder = true
    for expected in 0..<n where heap.pop() != expected {
        inOrder = false
    }
    print("d = \(d): pushes \(pushComparisons), pops \(heap.comparisons) comparisons, in order: \(inOrder)")
}
