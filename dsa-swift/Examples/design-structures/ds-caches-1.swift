// Generated from src/dsa/content/lessons/design-structures/ds-caches.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// Keys in order of use, oldest first: a doubly linked list plus a dictionary from each key to its
/// node, as in the LRU cache lesson. Every operation is O(1) on average.
final class RecencyList {
    final class Node {
        let key: String
        weak var previous: Node?
        var next: Node?
        init(key: String) { self.key = key }
    }

    private let head = Node(key: "")          // sentinel before the oldest
    private let tail = Node(key: "")          // sentinel after the newest
    private var nodes: [String: Node] = [:]

    init() {
        head.next = tail
        tail.previous = head
    }

    var isEmpty: Bool { nodes.isEmpty }

    private func unlink(_ node: Node) {
        node.previous!.next = node.next
        node.next!.previous = node.previous
    }

    private func linkAsNewest(_ node: Node) {
        let last = tail.previous!
        last.next = node
        node.previous = last
        node.next = tail
        tail.previous = node
    }

    func append(_ key: String) {
        let node = Node(key: key)
        nodes[key] = node
        linkAsNewest(node)
    }

    func moveToNewest(_ key: String) {
        guard let node = nodes[key] else { return }
        unlink(node)
        linkAsNewest(node)
    }

    func remove(_ key: String) {
        guard let node = nodes.removeValue(forKey: key) else { return }
        unlink(node)
    }

    func removeOldest() -> String? {
        guard let oldest = head.next, oldest !== tail else { return nil }
        remove(oldest.key)
        return oldest.key
    }
}

protocol Cache: AnyObject {
    func get(_ key: String) -> Int?
    func put(_ key: String, _ value: Int)
}

final class LRUCache: Cache {
    private let capacity: Int
    private var values: [String: Int] = [:]
    private let order = RecencyList()         // least recently used first

    init(capacity: Int) { self.capacity = capacity }

    func get(_ key: String) -> Int? {
        guard let value = values[key] else { return nil }
        order.moveToNewest(key)
        return value
    }

    func put(_ key: String, _ value: Int) {
        if values[key] != nil {               // an update is a use, never an eviction
            values[key] = value
            order.moveToNewest(key)
            return
        }
        if values.count == capacity, let victim = order.removeOldest() {
            values[victim] = nil
            print("  evicts \(victim)")
        }
        values[key] = value
        order.append(key)
    }
}

final class LFUCache: Cache {
    private let capacity: Int
    private var values: [String: Int] = [:]
    private var uses: [String: Int] = [:]
    private var buckets: [Int: RecencyList] = [:]   // use count -> its keys, least recent first
    private var fewestUses = 0

    init(capacity: Int) { self.capacity = capacity }

    private func bucket(_ count: Int) -> RecencyList {
        if let existing = buckets[count] { return existing }
        let made = RecencyList()
        buckets[count] = made
        return made
    }

    /// One more use: move the key from its count's bucket to the next one.
    private func touch(_ key: String) {
        let count = uses[key]!
        let old = bucket(count)
        old.remove(key)
        if old.isEmpty {
            buckets[count] = nil
            if fewestUses == count { fewestUses = count + 1 }
        }
        uses[key] = count + 1
        bucket(count + 1).append(key)
    }

    func get(_ key: String) -> Int? {
        guard let value = values[key] else { return nil }
        touch(key)
        return value
    }

    func put(_ key: String, _ value: Int) {
        if values[key] != nil {
            values[key] = value
            touch(key)
            return
        }
        if values.count == capacity, let victim = buckets[fewestUses]?.removeOldest() {
            if buckets[fewestUses]!.isEmpty { buckets[fewestUses] = nil }
            values[victim] = nil
            uses[victim] = nil
            print("  evicts \(victim)")
        }
        values[key] = value
        uses[key] = 1
        bucket(1).append(key)
        fewestUses = 1                        // a newcomer always has the fewest uses
    }
}

let caches: [(name: String, cache: any Cache)] = [("LRU", LRUCache(capacity: 3)), ("LFU", LFUCache(capacity: 3))]
for (name, cache) in caches {
    print("\(name):")
    cache.put("a", 1)
    for _ in 1...3 { _ = cache.get("a") }     // a is popular...
    cache.put("b", 2)
    cache.put("c", 3)
    _ = cache.get("b")
    _ = cache.get("c")                        // ...but b and c are more recent
    cache.put("d", 4)
    cache.put("e", 5)                         // e and f are a one-off scan
    cache.put("f", 6)
    print("  a is", cache.get("a").map(String.init) ?? "gone")
}
