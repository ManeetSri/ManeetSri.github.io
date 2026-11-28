// Generated from src/dsa/content/lessons/randomised/rand-streaming.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The k slowest responses in a stream, with a min-heap that never holds more than k values
struct MinHeap {
    private(set) var items: [Int] = []
    var count: Int { items.count }
    var top: Int? { items.first }

    mutating func insert(_ value: Int) {
        items.append(value)
        var child = items.count - 1
        while child > 0 && items[child] < items[(child - 1) / 2] {
            items.swapAt(child, (child - 1) / 2)
            child = (child - 1) / 2
        }
    }

    /// Replaces the smallest value with `value` and sifts it down
    mutating func replaceTop(with value: Int) {
        items[0] = value
        var parent = 0
        while true {
            let left = 2 * parent + 1, right = left + 1
            var smallest = parent
            if left < items.count && items[left] < items[smallest] { smallest = left }
            if right < items.count && items[right] < items[smallest] { smallest = right }
            if smallest == parent { return }
            items.swapAt(parent, smallest)
            parent = smallest
        }
    }
}

struct SlowestK {
    let k: Int
    private var heap = MinHeap()                  // the k largest so far; the smallest of them on top
    private(set) var seen = 0

    init(k: Int) { self.k = k }

    mutating func add(_ milliseconds: Int) {
        seen += 1
        if heap.count < k {
            heap.insert(milliseconds)
        } else if milliseconds > heap.top! {
            heap.replaceTop(with: milliseconds)   // the new value beats the weakest of the k
        }
    }

    var slowest: [Int] { heap.items.sorted(by: >) }
    var stored: Int { heap.count }
}

var tracker = SlowestK(k: 3)
for i in 1...100_000 {
    tracker.add(i * 7_919 % 1_000_003)            // a deterministic stand-in for response times
}
print("seen \(tracker.seen), stored \(tracker.stored)")
print("slowest three:", tracker.slowest)
