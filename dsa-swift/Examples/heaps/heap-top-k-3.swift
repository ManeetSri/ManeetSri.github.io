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

// The k closest points to (0, 0): a max-heap by distance, so the farthest of the k is on top
func closest(_ points: [(x: Int, y: Int)], k: Int) -> [(x: Int, y: Int)] {
    func squaredDistance(_ p: (x: Int, y: Int)) -> Int { p.x * p.x + p.y * p.y }
    var nearest = Heap<(x: Int, y: Int)>(areInIncreasingOrder: { squaredDistance($0) > squaredDistance($1) })
    for point in points {
        if nearest.count < k {
            nearest.insert(point)
        } else if squaredDistance(point) < squaredDistance(nearest.peek()!) {
            nearest.replaceTop(with: point)
        }
    }
    var result: [(x: Int, y: Int)] = []
    while let point = nearest.pop() {
        result.append(point)
    }
    return result.reversed()
}

let drivers = [(x: 3, y: 4), (x: 1, y: 1), (x: -2, y: 2), (x: 5, y: 0), (x: 0, y: -1), (x: 6, y: 6)]
for point in closest(drivers, k: 3) {
    print("(\(point.x), \(point.y)): squared distance \(point.x * point.x + point.y * point.y)")
}
