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

func mostUsed(_ tags: [String], k: Int) -> [String] {
    var counts: [String: Int] = [:]
    for tag in tags {
        counts[tag, default: 0] += 1
    }
    // a is worse than b: fewer uses, or as many uses and later in the alphabet
    func isWorse(_ a: (tag: String, uses: Int), _ b: (tag: String, uses: Int)) -> Bool {
        a.uses != b.uses ? a.uses < b.uses : a.tag > b.tag
    }
    var best = Heap<(tag: String, uses: Int)>(areInIncreasingOrder: isWorse)    // worst on top
    for (tag, uses) in counts {
        if best.count < k {
            best.insert((tag, uses))
        } else if isWorse(best.peek()!, (tag, uses)) {
            best.replaceTop(with: (tag, uses))
        }
    }
    var result: [String] = []
    while let entry = best.pop() {
        result.append("\(entry.tag) \(entry.uses)")
    }
    return result.reversed()                     // popped worst first, so reverse
}

let tags = ["swift", "ios", "dsa", "swift", "heap", "ios", "swift", "dsa", "ui", "heap", "dsa"]
print(mostUsed(tags, k: 3))
print(mostUsed(tags, k: 1))
