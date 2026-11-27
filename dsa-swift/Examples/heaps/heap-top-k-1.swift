// Generated from src/dsa/content/lessons/heaps/heap-top-k.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The heap from "Build a generic Heap<T>", compacted, plus replaceTop
struct Heap<Element> {
    private var items: [Element] = []
    private let areInIncreasingOrder: (Element, Element) -> Bool

    init(areInIncreasingOrder: @escaping (Element, Element) -> Bool) {
        self.areInIncreasingOrder = areInIncreasingOrder
    }

    var count: Int { items.count }
    var isEmpty: Bool { items.isEmpty }
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

// The k largest values seen so far, in a min-heap: its top is the kth largest
let k = 3
var best = Heap<Int>(areInIncreasingOrder: <)
for value in [12, 5, 31, 8, 27, 19, 3, 40] {
    if best.count < k {
        best.insert(value)
    } else if value > best.peek()! {
        best.replaceTop(with: value)             // the old kth largest drops out
    }
    if best.count == k {
        print("after \(value): kth largest is \(best.peek()!)")
    } else {
        print("after \(value): fewer than \(k) values")
    }
}

var largest: [Int] = []
while let value = best.pop() {
    largest.append(value)
}
print("the \(k) largest, biggest first:", Array(largest.reversed()))
