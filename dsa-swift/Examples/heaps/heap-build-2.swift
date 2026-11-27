// Generated from src/dsa/content/lessons/heaps/heap-build.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Heap<Element> {
    private var items: [Element] = []
    private let areInIncreasingOrder: (Element, Element) -> Bool

    init(areInIncreasingOrder: @escaping (Element, Element) -> Bool) {
        self.areInIncreasingOrder = areInIncreasingOrder
    }

    var count: Int { items.count }

    func peek() -> Element? {
        items.first
    }

    mutating func insert(_ element: Element) {
        items.append(element)
        var child = items.count - 1
        while child > 0 {
            let parent = (child - 1) / 2
            guard areInIncreasingOrder(items[child], items[parent]) else { return }
            items.swapAt(child, parent)
            child = parent
        }
    }

    mutating func pop() -> Element? {
        guard !items.isEmpty else { return nil }
        items.swapAt(0, items.count - 1)
        let top = items.removeLast()
        var parent = 0
        while true {
            let left = 2 * parent + 1
            let right = left + 1
            var first = parent
            if left < items.count && areInIncreasingOrder(items[left], items[first]) { first = left }
            if right < items.count && areInIncreasingOrder(items[right], items[first]) { first = right }
            if first == parent { break }
            items.swapAt(parent, first)
            parent = first
        }
        return top
    }
}

// A seeded random generator, so the test does the same thing every run
struct Dice {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func roll(_ range: ClosedRange<Int>) -> Int {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return range.lowerBound + Int((state >> 33) % UInt64(range.count))
    }
}

var dice = Dice(seed: 7)
var heap = Heap<Int>(areInIncreasingOrder: <)
var model: [Int] = []                                // sorted from largest to smallest
var mismatches = 0
for _ in 0..<10_000 {
    if dice.roll(0...9) < 6 {
        let value = dice.roll(-100...100)
        heap.insert(value)
        let position = model.firstIndex { $0 < value } ?? model.count
        model.insert(value, at: position)            // slow, but obviously right
    } else if heap.pop() != model.popLast() {
        mismatches += 1
    }
    if heap.peek() != model.last || heap.count != model.count {
        mismatches += 1
    }
}
print("10000 operations, \(heap.count) values left, \(mismatches) mismatches")
