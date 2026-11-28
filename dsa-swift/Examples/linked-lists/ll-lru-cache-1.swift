// Generated from src/dsa/content/lessons/linked-lists/ll-lru-cache.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class LRUCache {
    final class Node {
        let key: String
        var value: Int
        var next: Node?
        weak var previous: Node?

        init(key: String, value: Int) {
            self.key = key
            self.value = value
        }
    }

    let capacity: Int
    private var nodes: [String: Node] = [:]
    private let head = Node(key: "", value: 0)    // sentinel on the most recent side
    private let tail = Node(key: "", value: 0)    // sentinel on the least recent side

    init(capacity: Int) {
        precondition(capacity > 0, "An LRU cache needs room for at least one entry")
        self.capacity = capacity
        head.next = tail
        tail.previous = head
    }

    var count: Int { nodes.count }

    private func unlink(_ node: Node) {
        let before = node.previous!
        let after = node.next!
        before.next = after
        after.previous = before
    }

    private func insertAtFront(_ node: Node) {
        let first = head.next!
        node.previous = head
        node.next = first
        head.next = node
        first.previous = node
    }

    func value(for key: String) -> Int? {
        guard let node = nodes[key] else { return nil }
        unlink(node)
        insertAtFront(node)                       // reading counts as using
        return node.value
    }

    func setValue(_ value: Int, for key: String) {
        if let node = nodes[key] {                // update: no eviction needed
            node.value = value
            unlink(node)
            insertAtFront(node)
            return
        }
        if nodes.count == capacity {
            let oldest = tail.previous!
            unlink(oldest)
            nodes[oldest.key] = nil
            print("  evicted \(oldest.key)")
        }
        let node = Node(key: key, value: value)
        nodes[key] = node
        insertAtFront(node)
    }

    var keysByRecency: [String] {
        var keys: [String] = []
        var current = head.next!
        while current !== tail {
            keys.append(current.key)
            current = current.next!
        }
        return keys
    }
}

let thumbnails = LRUCache(capacity: 3)
thumbnails.setValue(120, for: "cat")
thumbnails.setValue(95, for: "dog")
thumbnails.setValue(240, for: "owl")
print(thumbnails.keysByRecency)

print("cat:", thumbnails.value(for: "cat") ?? 0)
print(thumbnails.keysByRecency)

print("set fox")
thumbnails.setValue(180, for: "fox")
print(thumbnails.keysByRecency)

thumbnails.setValue(250, for: "owl")
print(thumbnails.keysByRecency, thumbnails.count)
print("dog:", thumbnails.value(for: "dog") ?? 0, "owl:", thumbnails.value(for: "owl") ?? 0)
