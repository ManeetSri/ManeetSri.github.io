// A binary heap on an array (M39 · Build a generic Heap<T>).
//
// The heap is a complete binary tree stored level by level in an array: the children of index i are
// at 2i + 1 and 2i + 2, and its parent is at (i - 1) / 2. A closure, `areInIncreasingOrder`, decides
// the order: no element comes before its parent, so the element at index 0, the top, comes first of
// all. Inserting appends at the end and sifts the new element up; popping moves the last element to
// the top and sifts it down. Each walks one path between the root and a leaf, so it's O(log n).
//
// For production code, the swift-collections package has a `Heap` (a min-max heap) in HeapModule.

/// A priority queue: O(log n) `insert` and `pop`, and O(1) `peek()` at the element that comes first.
///
/// You choose what "first" means with a closure, exactly as with `sorted(by:)`. With `<` the top
/// is the smallest element (a min-heap); with `>` it's the largest (a max-heap).
///
/// ```swift
/// var tasks = Heap<(priority: Int, name: String)>(areInIncreasingOrder: { $0.priority < $1.priority })
/// tasks.insert((2, "reply"))
/// tasks.insert((1, "deploy"))
/// tasks.peek()?.name          // Optional("deploy")
///
/// var smallest = Heap.minHeap([5, 3, 8])
/// smallest.pop()              // Optional(3)
/// var largest: Heap = .maxHeap([5, 3, 8])
/// largest.pop()               // Optional(8)
/// ```
///
/// `Heap` is a value type: copying a heap gives an independent heap. It isn't a `Sequence`, because
/// neither iteration order would be honest: the array order isn't sorted, and sorted order would cost
/// O(n log n). Read `unordered` for the elements in array order, or `pop()` until it returns nil for
/// sorted order. Equal elements come out in no particular order: a heap isn't stable.
public struct Heap<Element> {
    /// The complete tree, level by level. No element comes before its parent.
    private var storage: [Element]

    /// True when the first argument should be nearer the top than the second.
    private let areInIncreasingOrder: (Element, Element) -> Bool

    /// Creates an empty heap whose top is the element that comes first by `areInIncreasingOrder`,
    /// which must be a strict ordering such as `<` or `>` (never `<=`). O(1).
    public init(areInIncreasingOrder: @escaping (Element, Element) -> Bool) {
        self.storage = []
        self.areInIncreasingOrder = areInIncreasingOrder
    }

    /// Creates a heap holding `elements`, ordered by `areInIncreasingOrder`. Uses bottom-up heapify,
    /// so it's O(n), faster than n separate inserts (O(n log n)).
    public init<S: Sequence>(_ elements: S, areInIncreasingOrder: @escaping (Element, Element) -> Bool)
    where S.Element == Element {
        self.storage = Array(elements)
        self.areInIncreasingOrder = areInIncreasingOrder
        heapify()
    }

    /// The number of elements in the heap. O(1).
    public var count: Int {
        storage.count
    }

    /// True when the heap holds no elements. O(1).
    public var isEmpty: Bool {
        storage.isEmpty
    }

    /// The elements in the heap's array order: the top first, then each level left to right. Only the
    /// first element's position is meaningful. O(1).
    public var unordered: [Element] {
        storage
    }

    /// The element that comes first, without removing it, or nil if the heap is empty. O(1).
    public func peek() -> Element? {
        storage.first
    }

    /// The element that comes first, the same as `peek()`. O(1).
    public var top: Element? {
        storage.first
    }

    /// Adds `element`: it joins the bottom level and sifts up past every parent it should come
    /// before. O(log n), plus an occasional O(n) when the array grows (amortised O(log n)).
    public mutating func insert(_ element: Element) {
        storage.append(element)
        siftUp(from: storage.count - 1)
    }

    /// Removes and returns the element that comes first, or nil if the heap is empty. The last
    /// element moves to the top and sifts down. O(log n).
    @discardableResult
    public mutating func pop() -> Element? {
        guard !storage.isEmpty else { return nil }
        storage.swapAt(0, storage.count - 1)
        let top = storage.removeLast()
        siftDown(from: 0)
        return top
    }

    /// Replaces the top with `element` and returns the old top: one sift instead of a `pop()` and an
    /// `insert(_:)`. If the heap is empty, `element` is inserted and the result is nil. O(log n).
    @discardableResult
    public mutating func replaceTop(with element: Element) -> Element? {
        guard !storage.isEmpty else {
            storage.append(element)
            return nil
        }
        let old = storage[0]
        storage[0] = element
        siftDown(from: 0)
        return old
    }

    /// Removes every element. With `keepingCapacity`, the array keeps its storage for reuse. O(n).
    public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
        storage.removeAll(keepingCapacity: keepCapacity)
    }

    /// Makes room for at least `minimumCapacity` elements, so inserting up to that many never has to
    /// grow the array. O(n).
    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        storage.reserveCapacity(minimumCapacity)
    }

    // MARK: - Sifting

    /// Moves the element at `index` up while it should come before its parent. O(log n).
    private mutating func siftUp(from index: Int) {
        var child = index
        while child > 0 {
            let parent = (child - 1) / 2
            guard areInIncreasingOrder(storage[child], storage[parent]) else { return }
            storage.swapAt(child, parent)
            child = parent
        }
    }

    /// Moves the element at `index` down while one of its children should come before it. O(log n).
    private mutating func siftDown(from index: Int) {
        heapSiftDown(&storage, from: index, count: storage.count, by: areInIncreasingOrder)
    }

    /// Bottom-up heapify: sift down every parent, from the last one back to the root. Most elements
    /// are near the bottom and travel only a step or two, so the total is O(n).
    private mutating func heapify() {
        for index in stride(from: storage.count / 2 - 1, through: 0, by: -1) {
            siftDown(from: index)
        }
    }
}

/// Sifts the element at `index` down within `items[0..<count]`, swapping it with whichever child
/// comes first while that child should come before it. Shared by `Heap` and `heapSort(by:)`.
/// O(log count).
private func heapSiftDown<Element>(
    _ items: inout [Element], from index: Int, count: Int, by areInIncreasingOrder: (Element, Element) -> Bool
) {
    var parent = index
    while true {
        let left = 2 * parent + 1
        let right = left + 1
        var first = parent
        if left < count && areInIncreasingOrder(items[left], items[first]) { first = left }
        if right < count && areInIncreasingOrder(items[right], items[first]) { first = right }
        if first == parent { return }
        items.swapAt(parent, first)
        parent = first
    }
}

extension Heap where Element: Comparable {
    /// Creates an empty min-heap: the top is the smallest element. O(1).
    public init() {
        self.init(areInIncreasingOrder: <)
    }

    /// Creates a min-heap holding `elements`, with bottom-up heapify. O(n).
    public init<S: Sequence>(_ elements: S) where S.Element == Element {
        self.init(elements, areInIncreasingOrder: <)
    }

    /// An empty min-heap: the top is the smallest element. O(1).
    public static func minHeap() -> Heap {
        Heap(areInIncreasingOrder: <)
    }

    /// A min-heap holding `elements`, with bottom-up heapify. O(n).
    public static func minHeap<S: Sequence>(_ elements: S) -> Heap where S.Element == Element {
        Heap(elements, areInIncreasingOrder: <)
    }

    /// An empty max-heap: the top is the largest element. O(1).
    public static func maxHeap() -> Heap {
        Heap(areInIncreasingOrder: >)
    }

    /// A max-heap holding `elements`, with bottom-up heapify. O(n).
    public static func maxHeap<S: Sequence>(_ elements: S) -> Heap where S.Element == Element {
        Heap(elements, areInIncreasingOrder: >)
    }
}

extension Heap: ExpressibleByArrayLiteral where Element: Comparable {
    /// Creates a min-heap from an array literal, with bottom-up heapify. O(n).
    public init(arrayLiteral elements: Element...) {
        self.init(elements, areInIncreasingOrder: <)
    }
}

extension Heap: CustomStringConvertible {
    /// The elements in array order, for example `Heap([1, 3, 2])`. Only the first is in a meaningful
    /// place. O(n).
    public var description: String {
        "Heap(\(storage))"
    }
}

// MARK: - Heap sort

extension Array {
    /// Sorts the array in place with heap sort, so that `areInIncreasingOrder` holds between
    /// neighbours. Builds a heap whose top is the element that belongs last, then repeatedly swaps
    /// the top to the end of the shrinking heap. O(n log n) in every case and O(1) extra memory, but
    /// not stable: equal elements can change order.
    public mutating func heapSort(by areInIncreasingOrder: (Element, Element) -> Bool) {
        // The top must be the element that sorts last, so the heap's order is the reverse one
        let total = count
        for index in stride(from: total / 2 - 1, through: 0, by: -1) {
            heapSiftDown(&self, from: index, count: total, by: { areInIncreasingOrder($1, $0) })
        }
        var end = total - 1
        while end > 0 {
            swapAt(0, end)                         // the last remaining element joins the sorted suffix
            heapSiftDown(&self, from: 0, count: end, by: { areInIncreasingOrder($1, $0) })
            end -= 1
        }
    }
}

extension Array where Element: Comparable {
    /// Sorts the array into increasing order in place with heap sort. O(n log n) in every case and
    /// O(1) extra memory, but not stable.
    public mutating func heapSort() {
        heapSort(by: <)
    }
}
