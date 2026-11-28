// Generated from src/dsa/content/lessons/heaps/heap-k-way-merge.mdx. Edit the lesson, then run
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

// Merge k sorted arrays: the heap holds one (value, list, position) entry per list
func mergeSorted(_ lists: [[Int]]) -> [Int] {
    var heads = Heap<(value: Int, list: Int, position: Int)>(areInIncreasingOrder: { $0.value < $1.value })
    for (list, values) in lists.enumerated() where !values.isEmpty {
        heads.insert((values[0], list, 0))
    }
    var merged: [Int] = []
    while let smallest = heads.pop() {
        merged.append(smallest.value)
        let next = smallest.position + 1
        if next < lists[smallest.list].count {
            heads.insert((lists[smallest.list][next], smallest.list, next))
        }
        print("took \(smallest.value) from list \(smallest.list); heap holds \(heads.count)")
    }
    return merged
}

print(mergeSorted([[1, 4, 9], [2, 3, 10], [], [0, 6]]))
