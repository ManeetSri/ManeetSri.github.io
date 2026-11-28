// Generated from src/dsa/content/lessons/heaps/heap-two-heaps.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The heap from "Build a generic Heap<T>", compacted, plus unordered and replaceTop
struct Heap<Element> {
    private var items: [Element] = []
    private let areInIncreasingOrder: (Element, Element) -> Bool

    init(areInIncreasingOrder: @escaping (Element, Element) -> Bool) {
        self.areInIncreasingOrder = areInIncreasingOrder
    }

    var count: Int { items.count }
    var isEmpty: Bool { items.isEmpty }
    var unordered: [Element] { items }
    func peek() -> Element? { items.first }

    mutating func insert(_ element: Element) {
        items.append(element)
        var child = items.count - 1
        while child > 0 && areInIncreasingOrder(items[child], items[(child - 1) / 2]) {
            items.swapAt(child, (child - 1) / 2)
            child = (child - 1) / 2
        }
    }

    mutating func pop() -> Element? {
        guard !items.isEmpty else { return nil }
        items.swapAt(0, items.count - 1)
        let top = items.removeLast()
        siftDownFromTop()
        return top
    }

    /// Replaces the top (the heap must not be empty) with one sift down
    mutating func replaceTop(with element: Element) {
        items[0] = element
        siftDownFromTop()
    }

    private mutating func siftDownFromTop() {
        var parent = 0
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

struct MedianTracker {
    private var lower = Heap<Int>(areInIncreasingOrder: >)    // the smaller half, largest on top
    private var upper = Heap<Int>(areInIncreasingOrder: <)    // the larger half, smallest on top

    mutating func add(_ value: Int) {
        // 1. Put it in the right half
        if let top = lower.peek(), value > top {
            upper.insert(value)
        } else {
            lower.insert(value)
        }
        // 2. Rebalance: lower holds as many values as upper, or one more
        if lower.count > upper.count + 1 {
            upper.insert(lower.pop()!)
        } else if upper.count > lower.count {
            lower.insert(upper.pop()!)
        }
    }

    var median: Double? {
        guard let middle = lower.peek() else { return nil }
        if lower.count > upper.count {
            return Double(middle)                                 // odd count: the middle value
        }
        return (Double(middle) + Double(upper.peek()!)) / 2       // even count: mean of the two middles
    }

    var halves: String {
        "\(lower.unordered.sorted()) | \(upper.unordered.sorted())"
    }
}

var tracker = MedianTracker()
print(tracker.median as Any)
for value in [5, 15, 1, 3, 8, 7, 9, 10] {
    tracker.add(value)
    print("add \(value): \(tracker.halves), median \(tracker.median!)")
}
