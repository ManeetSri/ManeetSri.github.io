// Reference solution: Build a priority queue. A binary heap in an array: the children of index i are
// at 2i + 1 and 2i + 2, and its parent at (i - 1) / 2. insert appends and sifts up; pop moves the last
// element to the top and sifts it down; both are O(log n). The array initialiser heapifies bottom-up
// in O(n): it sifts down every parent, from the last one back to the root.

public enum PriorityQueueFromScratch {
    public struct PriorityQueue<Element> {
        private var items: [Element] = []
        private let areInIncreasingOrder: (Element, Element) -> Bool

        public init(areInIncreasingOrder: @escaping (Element, Element) -> Bool) {
            self.areInIncreasingOrder = areInIncreasingOrder
        }

        public init(_ elements: [Element], areInIncreasingOrder: @escaping (Element, Element) -> Bool) {
            self.items = elements
            self.areInIncreasingOrder = areInIncreasingOrder
            for index in stride(from: items.count / 2 - 1, through: 0, by: -1) {
                siftDown(from: index)
            }
        }

        public var count: Int {
            items.count
        }

        public var isEmpty: Bool {
            items.isEmpty
        }

        public var unordered: [Element] {
            items
        }

        public func peek() -> Element? {
            items.first
        }

        public mutating func insert(_ element: Element) {
            items.append(element)
            var child = items.count - 1
            while child > 0 {
                let parent = (child - 1) / 2
                guard areInIncreasingOrder(items[child], items[parent]) else { break }
                items.swapAt(child, parent)
                child = parent
            }
        }

        public mutating func pop() -> Element? {
            guard !items.isEmpty else { return nil }
            items.swapAt(0, items.count - 1)
            let top = items.removeLast()
            siftDown(from: 0)
            return top
        }

        private mutating func siftDown(from index: Int) {
            var parent = index
            while true {
                let left = 2 * parent + 1
                let right = left + 1
                var first = parent
                if left < items.count && areInIncreasingOrder(items[left], items[first]) { first = left }
                if right < items.count && areInIncreasingOrder(items[right], items[first]) { first = right }
                if first == parent { return }
                items.swapAt(parent, first)
                parent = first
            }
        }
    }
}
