// Generated from src/dsa/content/lessons/patterns/pat-templates-search-sort.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// A small binary heap: `isHigher(a, b)` says whether a belongs nearer the top than b
struct Heap<Element> {
    private var items: [Element] = []
    private let isHigher: (Element, Element) -> Bool
    init(_ isHigher: @escaping (Element, Element) -> Bool) { self.isHigher = isHigher }

    var count: Int { items.count }
    var top: Element? { items.first }

    mutating func push(_ element: Element) {
        items.append(element)
        var child = items.count - 1
        while child > 0, isHigher(items[child], items[(child - 1) / 2]) {
            items.swapAt(child, (child - 1) / 2)
            child = (child - 1) / 2
        }
    }

    mutating func pop() -> Element? {
        guard !items.isEmpty else { return nil }
        items.swapAt(0, items.count - 1)
        let removed = items.removeLast()
        var parent = 0
        while true {
            var best = parent
            for child in [2 * parent + 1, 2 * parent + 2] where child < items.count && isHigher(items[child], items[best]) {
                best = child
            }
            if best == parent { return removed }
            items.swapAt(parent, best)
            parent = best
        }
    }
}

// Top k: a MIN-heap of the k largest so far; the smallest of them sits on top, ready to be beaten
func largest(_ k: Int, of items: [Int]) -> [Int] {
    var heap = Heap<Int>(<)
    for value in items {
        heap.push(value)
        if heap.count > k { _ = heap.pop() }      // drop the smallest: it isn't in the top k
    }
    var result: [Int] = []
    while let value = heap.pop() { result.append(value) }
    return result.reversed()                      // largest first
}

// K-way merge: the heap holds the smallest unused value of each list, with where it came from
func mergeSorted(_ lists: [[Int]]) -> [Int] {
    var heap = Heap<(value: Int, list: Int, index: Int)>({ $0.value < $1.value })
    for (list, values) in lists.enumerated() where !values.isEmpty {
        heap.push((values[0], list, 0))
    }
    var merged: [Int] = []
    while let (value, list, index) = heap.pop() {
        merged.append(value)
        if index + 1 < lists[list].count {        // replace it with the next value from the same list
            heap.push((lists[list][index + 1], list, index + 1))
        }
    }
    return merged
}

// Two heaps: the running median. `lower` is a max-heap of the smaller half, `upper` a min-heap of the rest
func runningMedians(_ stream: [Int]) -> [Double] {
    var lower = Heap<Int>(>)
    var upper = Heap<Int>(<)
    var medians: [Double] = []
    for value in stream {
        if let top = lower.top, value > top { upper.push(value) } else { lower.push(value) }
        // Rebalance so lower has the same number as upper, or one more
        if lower.count > upper.count + 1 { upper.push(lower.pop()!) }
        if upper.count > lower.count { lower.push(upper.pop()!) }
        medians.append(lower.count > upper.count ? Double(lower.top!) : Double(lower.top! + upper.top!) / 2)
    }
    return medians
}

print(largest(3, of: [5, 1, 9, 3, 7, 9, 2]))
print(mergeSorted([[1, 4, 9], [2, 3, 10], [], [5]]))
print(runningMedians([5, 15, 1, 3, 8]))
