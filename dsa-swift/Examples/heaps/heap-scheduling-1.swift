// Generated from src/dsa/content/lessons/heaps/heap-scheduling.mdx. Edit the lesson, then run
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

// Fewest rooms for half-open meetings: a min-heap of the end times of rooms in use
func roomsNeeded(_ meetings: [(start: Int, end: Int)]) -> Int {
    let byStart = meetings.sorted { $0.start < $1.start }
    var endTimes = Heap<Int>(areInIncreasingOrder: <)        // the earliest-free room on top
    var most = 0
    for meeting in byStart {
        if let earliest = endTimes.peek(), earliest <= meeting.start {
            endTimes.replaceTop(with: meeting.end)            // reuse the room that's free
        } else {
            endTimes.insert(meeting.end)                      // every room is busy: open another
        }
        most = max(most, endTimes.count)
        print("\(meeting.start)-\(meeting.end): rooms in use \(endTimes.count), next free at \(endTimes.peek()!)")
    }
    return most
}

print(roomsNeeded([(9, 10), (9, 12), (10, 11), (11, 13), (12, 13)]))
