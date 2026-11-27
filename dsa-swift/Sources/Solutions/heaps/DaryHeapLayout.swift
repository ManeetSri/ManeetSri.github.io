// Reference solution: A heap with d children per node. The binary heap's index maths with 2 replaced by
// d. Push sifts up past strictly larger parents; pop swaps the root with the last element, removes it,
// and sifts down by swapping with the leftmost smallest child while that child is strictly smaller.
// The array initialiser sifts down every parent from (count - 2) / d back to 0.
// O(log_d n) push, O(d log_d n) pop, O(n) build.

public enum DaryHeapLayout {
    public struct DaryMinHeap {
        public let arity: Int
        public private(set) var storage: [Int] = []

        public init(arity: Int) {
            self.arity = arity
        }

        public init(arity: Int, items: [Int]) {
            self.arity = arity
            storage = items
            guard storage.count >= 2 else { return }
            for index in stride(from: (storage.count - 2) / arity, through: 0, by: -1) {
                siftDown(from: index)
            }
        }

        public var count: Int { storage.count }

        public func peek() -> Int? { storage.first }

        public mutating func push(_ value: Int) {
            storage.append(value)
            var child = storage.count - 1
            while child > 0 {
                let parent = (child - 1) / arity
                guard storage[child] < storage[parent] else { return }
                storage.swapAt(child, parent)
                child = parent
            }
        }

        public mutating func pop() -> Int? {
            guard !storage.isEmpty else { return nil }
            storage.swapAt(0, storage.count - 1)
            let top = storage.removeLast()
            siftDown(from: 0)
            return top
        }

        private mutating func siftDown(from start: Int) {
            var parent = start
            while true {
                let firstChild = arity * parent + 1
                guard firstChild < storage.count else { return }
                var smallest = firstChild                    // the leftmost smallest child
                for child in (firstChild + 1)..<Swift.min(firstChild + arity, storage.count)
                where storage[child] < storage[smallest] {
                    smallest = child
                }
                guard storage[smallest] < storage[parent] else { return }
                storage.swapAt(parent, smallest)
                parent = smallest
            }
        }
    }
}
