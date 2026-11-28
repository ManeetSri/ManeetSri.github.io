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

// The skyline from M33, with a max-heap and lazy deletion: O(n log n)
func skyline(_ buildings: [[Int]]) -> [[Int]] {
    // A start is (left, -height) and an end is (right, height): the same tie-breaking order as before
    var events: [(x: Int, key: Int)] = []
    for building in buildings {
        events.append((building[0], -building[2]))
        events.append((building[1], building[2]))
    }
    events.sort { ($0.x, $0.key) < ($1.x, $1.key) }

    var active = Heap<Int>(areInIncreasingOrder: >)      // heights, tallest on top, maybe some stale
    var pendingRemoval: [Int: Int] = [:]                 // height -> copies that have ended
    var points: [[Int]] = []
    for event in events {
        if event.key < 0 {
            active.insert(-event.key)
        } else {
            pendingRemoval[event.key, default: 0] += 1   // don't search for it: just note it
        }
        // Only the top matters, so only clean up stale heights when they reach the top
        while let top = active.peek(), let pending = pendingRemoval[top], pending > 0 {
            _ = active.pop()
            pendingRemoval[top] = pending - 1
        }
        let height = active.peek() ?? 0
        if points.last?[1] != height {
            points.append([event.x, height])
        }
    }
    return points
}

print(skyline([[1, 5, 3], [2, 4, 6], [3, 8, 4], [10, 12, 2]]))
print(skyline([[0, 3, 5], [3, 6, 5]]))
print(skyline([[1, 4, 2], [1, 4, 7], [1, 4, 5]]))
