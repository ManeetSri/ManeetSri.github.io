// Problem: Build a priority queue (M39 · Build a generic Heap<T>)

public enum PriorityQueueFromScratch {
    /// A binary heap stored in an array, level by level: the children of index i are at 2i + 1 and
    /// 2i + 2. `areInIncreasingOrder(a, b)` is true when a should be nearer the top than b, so `<`
    /// makes a min-heap and `>` a max-heap.
    public struct PriorityQueue<Element> {
        // Write your solution here, then run:
        // swift test --filter PriorityQueueFromScratchTests
        // Add the private storage you need: an array, and the comparator (stored, so it's @escaping).

        /// Creates an empty priority queue ordered by `areInIncreasingOrder`.
        public init(areInIncreasingOrder: @escaping (Element, Element) -> Bool) {
        }

        /// Creates a priority queue holding `elements`, in O(n) with bottom-up heapify.
        public init(_ elements: [Element], areInIncreasingOrder: @escaping (Element, Element) -> Bool) {
        }

        /// How many elements the queue holds.
        public var count: Int {
            return 0
        }

        /// True when the queue holds no elements.
        public var isEmpty: Bool {
            return true
        }

        /// The underlying array, level by level, with the top at index 0.
        public var unordered: [Element] {
            return []
        }

        /// The element that comes first, without removing it, or nil if the queue is empty. O(1).
        public func peek() -> Element? {
            return nil
        }

        /// Adds `element`. O(log n).
        public mutating func insert(_ element: Element) {
        }

        /// Removes and returns the element that comes first, or nil if the queue is empty. O(log n).
        public mutating func pop() -> Element? {
            return nil
        }
    }
}
