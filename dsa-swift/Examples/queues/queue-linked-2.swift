// Generated from src/dsa/content/lessons/queues/queue-linked.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class Node {
    let value: Int
    var next: Node?
    init(_ value: Int) { self.value = value }
}

// A struct this time: copies share the same nodes
struct SharedQueue {
    var head: Node?
    var tail: Node?

    mutating func enqueue(_ value: Int) {
        let node = Node(value)
        if let tail { tail.next = node } else { head = node }
        tail = node
    }

    var values: [Int] {
        var result: [Int] = []
        var node = head
        while let current = node {
            result.append(current.value)
            node = current.next
        }
        return result
    }
}

var original = SharedQueue()
original.enqueue(1)
original.enqueue(2)
var copy = original
copy.enqueue(3)                    // changes the node both copies share
print("copy:", copy.values)
print("original:", original.values)
