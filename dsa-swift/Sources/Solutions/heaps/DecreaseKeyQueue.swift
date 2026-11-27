// Reference solution: A priority queue with changeable keys. A binary min-heap of ids, ordered by
// (key, id), plus a position array recording where each id sits in the heap (-1 when it isn't queued).
// Every swap goes through one helper that updates both positions, so any id is found in O(1). Changing
// a key sifts up and down; removing swaps with the last entry and re-sifts the moved one.
// O(1) lookups, O(log n) push, remove and popMin.

public enum DecreaseKeyQueue {
    public struct IndexedQueue {
        private var heap: [Int] = []                     // ids, in heap order
        private var keys: [Int]                          // keys[id], meaningful while id is queued
        private var position: [Int]                      // index of id in heap, or -1

        public init(capacity: Int) {
            keys = Array(repeating: 0, count: capacity)
            position = Array(repeating: -1, count: capacity)
        }

        public var count: Int { heap.count }
        public var isEmpty: Bool { heap.isEmpty }

        public func contains(_ id: Int) -> Bool { position[id] >= 0 }

        public func key(of id: Int) -> Int? { contains(id) ? keys[id] : nil }

        public func peek() -> (id: Int, key: Int)? {
            heap.first.map { ($0, keys[$0]) }
        }

        public mutating func push(_ id: Int, key: Int) {
            keys[id] = key
            if position[id] < 0 {
                heap.append(id)
                position[id] = heap.count - 1
            }
            siftUp(from: position[id])                   // a smaller key moves up…
            siftDown(from: position[id])                 // …a larger one down
        }

        @discardableResult
        public mutating func remove(_ id: Int) -> Bool {
            let index = position[id]
            guard index >= 0 else { return false }
            swapAt(index, heap.count - 1)                 // move it to the end and drop it
            heap.removeLast()
            position[id] = -1
            if index < heap.count {                      // fix the entry that took its place
                let moved = heap[index]
                siftUp(from: index)
                siftDown(from: position[moved])
            }
            return true
        }

        public mutating func popMin() -> (id: Int, key: Int)? {
            guard let top = heap.first else { return nil }
            remove(top)
            return (top, keys[top])
        }

        /// True when the entry at heap index i should be nearer the top than the one at j.
        private func comesFirst(_ i: Int, _ j: Int) -> Bool {
            (keys[heap[i]], heap[i]) < (keys[heap[j]], heap[j])
        }

        /// The only place entries move, so positions always stay correct.
        private mutating func swapAt(_ i: Int, _ j: Int) {
            heap.swapAt(i, j)
            position[heap[i]] = i
            position[heap[j]] = j
        }

        private mutating func siftUp(from start: Int) {
            var child = start
            while child > 0 {
                let parent = (child - 1) / 2
                guard comesFirst(child, parent) else { return }
                swapAt(child, parent)
                child = parent
            }
        }

        private mutating func siftDown(from start: Int) {
            var parent = start
            while true {
                let left = 2 * parent + 1
                var best = parent
                if left < heap.count && comesFirst(left, best) { best = left }
                if left + 1 < heap.count && comesFirst(left + 1, best) { best = left + 1 }
                if best == parent { return }
                swapAt(parent, best)
                parent = best
            }
        }
    }
}
