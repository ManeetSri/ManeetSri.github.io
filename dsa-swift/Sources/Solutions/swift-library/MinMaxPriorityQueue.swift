// Reference solution: A priority queue with both ends. A min-max heap, the structure behind
// swift-collections' Heap: an array-shaped binary tree whose even levels (0, 2, …) are min levels, where a
// node is no larger than everything below it, and whose odd levels are max levels. The minimum is the
// root and the maximum is one of its children. Inserting bubbles up through grandparents on the right kind
// of level; popping trickles down through children and grandchildren. O(log n) per change, O(1) to peek,
// O(n) to build from an array.

public enum MinMaxPriorityQueue {
    public struct Queue<Element: Comparable> {
        private var items: [Element] = []

        public init() {}

        public init(_ elements: [Element]) {
            items = elements
            if items.count > 1 {
                for i in stride(from: items.count / 2 - 1, through: 0, by: -1) { trickleDown(i) }
            }
        }

        public var count: Int { items.count }
        public var isEmpty: Bool { items.isEmpty }
        public var min: Element? { items.first }
        public var max: Element? { maxIndex.map { items[$0] } }

        public mutating func insert(_ element: Element) {
            items.append(element)
            bubbleUp(items.count - 1)
        }

        public mutating func popMin() -> Element? {
            items.isEmpty ? nil : remove(at: 0)
        }

        public mutating func popMax() -> Element? {
            guard let index = maxIndex else { return nil }
            return remove(at: index)
        }

        private var maxIndex: Int? {
            switch items.count {
            case 0: return nil
            case 1: return 0
            case 2: return 1
            default: return items[1] >= items[2] ? 1 : 2
            }
        }

        private func isMinLevel(_ i: Int) -> Bool {
            ((i + 1).bitWidth - (i + 1).leadingZeroBitCount - 1) % 2 == 0
        }

        private mutating func remove(at index: Int) -> Element {
            let removed = items[index]
            let last = items.removeLast()
            if index < items.count {
                items[index] = last
                trickleDown(index)
            }
            return removed
        }

        private mutating func bubbleUp(_ index: Int) {
            guard index > 0 else { return }
            let parent = (index - 1) / 2
            let onMin = isMinLevel(index)
            if onMin ? items[index] > items[parent] : items[index] < items[parent] {
                items.swapAt(index, parent)
                bubbleUp(parent, towardsMax: onMin)
            } else {
                bubbleUp(index, towardsMax: !onMin)
            }
        }

        private mutating func bubbleUp(_ index: Int, towardsMax: Bool) {
            var i = index
            while i >= 3 {
                let grandparent = ((i - 1) / 2 - 1) / 2
                guard towardsMax ? items[i] > items[grandparent] : items[i] < items[grandparent] else { return }
                items.swapAt(i, grandparent)
                i = grandparent
            }
        }

        private mutating func trickleDown(_ index: Int) {
            let towardsMax = !isMinLevel(index)
            func better(_ a: Element, _ b: Element) -> Bool { towardsMax ? a > b : a < b }
            var i = index
            while true {
                let firstChild = 2 * i + 1
                guard firstChild < items.count else { return }
                var best = firstChild
                for candidate in [firstChild + 1, 4 * i + 3, 4 * i + 4, 4 * i + 5, 4 * i + 6]
                where candidate < items.count && better(items[candidate], items[best]) {
                    best = candidate
                }
                guard better(items[best], items[i]) else { return }
                items.swapAt(i, best)
                if best <= firstChild + 1 { return }        // a child: done
                let parent = (best - 1) / 2
                if better(items[parent], items[best]) { items.swapAt(best, parent) }
                i = best
            }
        }
    }
}
