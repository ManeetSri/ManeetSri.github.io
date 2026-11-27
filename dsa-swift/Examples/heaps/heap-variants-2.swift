// Generated from src/dsa/content/lessons/heaps/heap-variants.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// A min-heap of ids 0..<capacity, each with a key, supporting decreaseKey
struct IndexedMinHeap {
    private var heap: [Int] = []          // ids, arranged as a binary heap by their keys
    private var position: [Int]           // position[id]: where id sits in heap, or -1 if absent
    private var key: [Int]

    init(capacity: Int) {
        position = Array(repeating: -1, count: capacity)
        key = Array(repeating: 0, count: capacity)
    }

    var isEmpty: Bool { heap.isEmpty }

    func contains(_ id: Int) -> Bool {
        position[id] != -1
    }

    mutating func insert(_ id: Int, key newKey: Int) {
        key[id] = newKey
        heap.append(id)
        position[id] = heap.count - 1
        siftUp(from: heap.count - 1)
    }

    /// Lowers the key of an id already in the heap. A smaller key can only move up. O(log n)
    mutating func decreaseKey(_ id: Int, to newKey: Int) {
        precondition(contains(id) && newKey <= key[id], "decreaseKey needs a smaller key for an id in the heap")
        key[id] = newKey
        siftUp(from: position[id])
    }

    mutating func popMin() -> (id: Int, key: Int)? {
        guard let top = heap.first else { return nil }
        swapNodes(0, heap.count - 1)
        heap.removeLast()
        position[top] = -1
        siftDown(from: 0)
        return (top, key[top])
    }

    /// Every swap must update both ids' positions
    private mutating func swapNodes(_ i: Int, _ j: Int) {
        heap.swapAt(i, j)
        position[heap[i]] = i
        position[heap[j]] = j
    }

    private mutating func siftUp(from index: Int) {
        var child = index
        while child > 0 && key[heap[child]] < key[heap[(child - 1) / 2]] {
            swapNodes(child, (child - 1) / 2)
            child = (child - 1) / 2
        }
    }

    private mutating func siftDown(from index: Int) {
        var parent = index
        while true {
            let left = 2 * parent + 1
            let right = left + 1
            var smallest = parent
            if left < heap.count && key[heap[left]] < key[heap[smallest]] { smallest = left }
            if right < heap.count && key[heap[right]] < key[heap[smallest]] { smallest = right }
            if smallest == parent { return }
            swapNodes(parent, smallest)
            parent = smallest
        }
    }
}

let towns = ["Ayr", "Bath", "Cork", "Derry", "Ely"]
var queue = IndexedMinHeap(capacity: towns.count)
for (id, distance) in [0, 7, 9, 14, 20].enumerated() {
    queue.insert(id, key: distance)
}

func popAndPrint() {
    let (id, distance) = queue.popMin()!
    print("pop \(towns[id]) at \(distance)")
}

popAndPrint()
queue.decreaseKey(2, to: 5)               // a shorter way to Cork
queue.decreaseKey(4, to: 11)              // and to Ely
popAndPrint()
queue.decreaseKey(3, to: 8)               // and to Derry
print("Bath still queued:", queue.contains(1), "| Ayr still queued:", queue.contains(0))
while !queue.isEmpty {
    popAndPrint()
}
