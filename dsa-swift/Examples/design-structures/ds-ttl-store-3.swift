// Generated from src/dsa/content/lessons/design-structures/ds-ttl-store.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The heap from "Build a generic Heap<T>", compacted, with peek
struct Heap<Element> {
    private var items: [Element] = []
    private let areInIncreasingOrder: (Element, Element) -> Bool

    init(areInIncreasingOrder: @escaping (Element, Element) -> Bool) {
        self.areInIncreasingOrder = areInIncreasingOrder
    }

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
        var parent = 0
        while true {
            let left = 2 * parent + 1
            let right = left + 1
            var first = parent
            if left < items.count && areInIncreasingOrder(items[left], items[first]) { first = left }
            if right < items.count && areInIncreasingOrder(items[right], items[first]) { first = right }
            if first == parent { return top }
            items.swapAt(parent, first)
            parent = first
        }
    }
}

struct TTLStore {
    private var entries: [String: (value: String, expiresAt: Int)] = [:]
    private var deadlines = Heap<(expiresAt: Int, key: String)>(areInIncreasingOrder: { $0.expiresAt < $1.expiresAt })

    mutating func set(_ value: String, for key: String, ttl: Int, now: Int) {
        entries[key] = (value, now + ttl)
        deadlines.insert((now + ttl, key))             // any earlier deadline for key is now stale
    }

    mutating func value(for key: String, now: Int) -> String? {
        guard let entry = entries[key], entry.expiresAt > now else { return nil }
        return entry.value
    }

    /// Eager cleanup: throw out everything whose deadline has passed, earliest first.
    mutating func count(now: Int) -> Int {
        while let next = deadlines.peek(), next.expiresAt <= now {
            _ = deadlines.pop()
            if let entry = entries[next.key], entry.expiresAt == next.expiresAt {
                entries[next.key] = nil
                print("  expired \(next.key)")
            } else {
                print("  skipped a stale deadline for \(next.key)")
            }
        }
        return entries.count
    }
}

var cache = TTLStore()
cache.set("v1", for: "feed", ttl: 10, now: 0)          // expires at 10
cache.set("v1", for: "profile", ttl: 30, now: 0)       // expires at 30
cache.set("v2", for: "feed", ttl: 10, now: 5)          // refreshed: expires at 15 instead
print("count at 12:", cache.count(now: 12))
print("count at 15:", cache.count(now: 15))
print("feed at 15:", cache.value(for: "feed", now: 15) ?? "gone")
print("count at 40:", cache.count(now: 40))
