// Reference solution: A queue that's fast at both ends. A min-max heap: a complete tree in an array whose
// levels alternate between min levels (each node ≤ everything below it) and max levels (≥ everything
// below). The smallest value is the root and the largest one of its children. Insert bubbles up through
// grandparents on the right kind of level; pops trickle down through children and grandchildren.
// O(1) min and max, O(log n) insert, popMin and popMax.

public enum MinMaxHeapQueue {
    public struct BothEndsQueue {
        private var items: [Int] = []

        public init() {}

        public var count: Int { items.count }
        public var isEmpty: Bool { items.isEmpty }
        public var min: Int? { items.first }
        public var max: Int? {
            switch items.count {
            case 0: return nil
            case 1: return items[0]
            case 2: return items[1]
            default: return Swift.max(items[1], items[2])
            }
        }

        public mutating func insert(_ value: Int) {
            items.append(value)
            let i = items.count - 1
            guard i > 0 else { return }
            let parent = (i - 1) / 2
            if Self.isMinLevel(i) {
                if items[i] > items[parent] {
                    items.swapAt(i, parent)
                    bubbleUp(from: parent, isMax: true)
                } else {
                    bubbleUp(from: i, isMax: false)
                }
            } else {
                if items[i] < items[parent] {
                    items.swapAt(i, parent)
                    bubbleUp(from: parent, isMax: false)
                } else {
                    bubbleUp(from: i, isMax: true)
                }
            }
        }

        public mutating func popMin() -> Int? {
            remove(at: 0)
        }

        public mutating func popMax() -> Int? {
            guard items.count > 1 else { return remove(at: 0) }
            return remove(at: items.count == 2 || items[1] >= items[2] ? 1 : 2)
        }

        private mutating func remove(at index: Int) -> Int? {
            guard index < items.count else { return nil }
            let removed = items[index]
            let last = items.removeLast()
            if index < items.count {
                items[index] = last
                trickleDown(from: index, isMax: !Self.isMinLevel(index))
            }
            return removed
        }

        /// True when `a` should be nearer the top than `b` on this kind of level.
        private static func beats(_ a: Int, _ b: Int, isMax: Bool) -> Bool {
            isMax ? a > b : a < b
        }

        private static func isMinLevel(_ i: Int) -> Bool {
            (Int.bitWidth - (i + 1).leadingZeroBitCount - 1) % 2 == 0
        }

        /// Moves items[i] up through the levels of its own kind, comparing with grandparents.
        private mutating func bubbleUp(from start: Int, isMax: Bool) {
            var i = start
            while i > 2 {
                let grandparent = ((i - 1) / 2 - 1) / 2
                guard Self.beats(items[i], items[grandparent], isMax: isMax) else { return }
                items.swapAt(i, grandparent)
                i = grandparent
            }
        }

        /// Moves items[i] down, looking at its children and grandchildren for the most extreme value.
        private mutating func trickleDown(from start: Int, isMax: Bool) {
            var i = start
            while 2 * i + 1 < items.count {
                var best = 2 * i + 1                             // among children and grandchildren
                if best + 1 < items.count && Self.beats(items[best + 1], items[best], isMax: isMax) {
                    best += 1
                }
                let firstGrandchild = 4 * i + 3
                if firstGrandchild < items.count {
                    for candidate in firstGrandchild...Swift.min(firstGrandchild + 3, items.count - 1)
                    where Self.beats(items[candidate], items[best], isMax: isMax) {
                        best = candidate
                    }
                }
                guard Self.beats(items[best], items[i], isMax: isMax) else { return }
                items.swapAt(best, i)
                if best <= 2 * i + 2 { return }                  // a child: nothing below it to fix
                let parent = (best - 1) / 2                      // a grandchild: fix the level between
                if Self.beats(items[parent], items[best], isMax: isMax) {
                    items.swapAt(parent, best)
                }
                i = best
            }
        }
    }
}
