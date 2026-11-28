// Generated from src/dsa/content/lessons/advanced-structures/as-lfu.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class LFUCache {
    final class Node {
        let key: String
        var value: Int
        var frequency = 1
        var next: Node?
        weak var previous: Node?

        init(key: String, value: Int) {
            self.key = key
            self.value = value
        }
    }

    // One frequency's keys: a doubly linked list with sentinels, most recently used first
    final class Bucket {
        let head = Node(key: "", value: 0)
        let tail = Node(key: "", value: 0)

        init() {
            head.next = tail
            tail.previous = head
        }

        var isEmpty: Bool { head.next === tail }

        func insertAtFront(_ node: Node) {
            let first = head.next!
            node.previous = head
            node.next = first
            head.next = node
            first.previous = node
        }

        func unlink(_ node: Node) {
            node.previous!.next = node.next
            node.next!.previous = node.previous
        }

        var keys: [String] {
            var result: [String] = []
            var current = head.next!
            while current !== tail {
                result.append(current.key)
                current = current.next!
            }
            return result
        }
    }

    let capacity: Int
    private var nodes: [String: Node] = [:]       // key → its node
    private var buckets: [Int: Bucket] = [:]      // frequency → the keys used that often
    private var minFrequency = 0                  // the lowest frequency in the cache

    init(capacity: Int) {
        self.capacity = capacity
    }

    private func bucket(for frequency: Int) -> Bucket {
        if let bucket = buckets[frequency] { return bucket }
        let bucket = Bucket()
        buckets[frequency] = bucket
        return bucket
    }

    // A use: move the node from its frequency's list to the front of the next one
    private func touch(_ node: Node) {
        let old = buckets[node.frequency]!
        old.unlink(node)
        if old.isEmpty {
            buckets[node.frequency] = nil
            if minFrequency == node.frequency { minFrequency += 1 }
        }
        node.frequency += 1
        bucket(for: node.frequency).insertAtFront(node)
    }

    func value(for key: String) -> Int? {
        guard let node = nodes[key] else { return nil }
        touch(node)
        return node.value
    }

    func setValue(_ value: Int, for key: String) {
        guard capacity > 0 else { return }
        if let node = nodes[key] {                // an update is a use; nothing is evicted
            node.value = value
            touch(node)
            return
        }
        if nodes.count == capacity {              // evict: lowest frequency, least recent of those
            let bucket = buckets[minFrequency]!
            let victim = bucket.tail.previous!
            bucket.unlink(victim)
            if bucket.isEmpty { buckets[minFrequency] = nil }
            nodes[victim.key] = nil
            print("  evicted \(victim.key) (used \(victim.frequency)x)")
        }
        let node = Node(key: key, value: value)
        nodes[key] = node
        bucket(for: 1).insertAtFront(node)
        minFrequency = 1                          // a new key is always the least used
    }

    var summary: String {
        buckets.keys.sorted().map { "\($0)x: \(buckets[$0]!.keys)" }.joined(separator: "  ")
    }
}

let recent = LFUCache(capacity: 3)          // an emoji keyboard's "frequently used" row
recent.setValue(1, for: "smile")
recent.setValue(2, for: "heart")
recent.setValue(3, for: "thumbs")
_ = recent.value(for: "smile")
_ = recent.value(for: "smile")
_ = recent.value(for: "heart")
print(recent.summary)

print("set fire")
recent.setValue(4, for: "fire")
_ = recent.value(for: "fire")
print(recent.summary)

print("set star")
recent.setValue(5, for: "star")
print(recent.summary)
print("heart:", recent.value(for: "heart") ?? 0, "smile:", recent.value(for: "smile") ?? 0)
print(recent.summary)
