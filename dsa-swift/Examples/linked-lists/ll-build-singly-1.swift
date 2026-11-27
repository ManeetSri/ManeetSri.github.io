// Generated from src/dsa/content/lessons/linked-lists/ll-build-singly.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class LinkedList<Element> {
    final class Node {
        var value: Element
        var next: Node?

        init(_ value: Element, next: Node? = nil) {
            self.value = value
            self.next = next
        }
    }

    private var head: Node?
    private var tail: Node?
    private(set) var count = 0

    var isEmpty: Bool { head == nil }
    var first: Element? { head?.value }
    var last: Element? { tail?.value }

    func prepend(_ value: Element) {
        head = Node(value, next: head)
        if tail == nil {
            tail = head
        }
        count += 1
    }

    func append(_ value: Element) {
        let node = Node(value)
        if let tail {
            tail.next = node
        } else {
            head = node
        }
        tail = node
        count += 1
    }
}

extension LinkedList: CustomStringConvertible {
    var description: String {
        var parts: [String] = []
        var current = head
        while let node = current {
            parts.append("\(node.value)")
            current = node.next
        }
        parts.append("nil")
        return parts.joined(separator: " -> ")
    }
}

let list = LinkedList<Int>()
print(list, list.isEmpty)
list.append(2)
list.append(3)
list.prepend(1)
print(list)
print("count:", list.count, "first:", list.first ?? 0, "last:", list.last ?? 0)

let words = LinkedList<String>()
words.prepend("world")
words.prepend("hello")
print(words)
