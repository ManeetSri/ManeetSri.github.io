// Generated from src/dsa/content/lessons/linked-lists/ll-build-singly.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class Node {
    var value: Int
    var next: Node?
    init(_ value: Int) { self.value = value }
}

struct BrokenList {
    var head: Node?
    var tail: Node?
    var count = 0

    mutating func append(_ value: Int) {
        let node = Node(value)
        if let tail { tail.next = node } else { head = node }
        tail = node
        count += 1
    }

    var values: [Int] {
        var result: [Int] = []
        var current = head
        while let node = current {
            result.append(node.value)
            current = node.next
        }
        return result
    }
}

var a = BrokenList()
a.append(1)
var b = a
b.append(2)
print(a.values, a.count)
print(b.values, b.count)
