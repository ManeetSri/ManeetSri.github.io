// Generated from src/dsa/content/lessons/queues/queue-linked.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class Node<Element> {
    let value: Element
    var next: Node?

    init(_ value: Element) {
        self.value = value
    }
}

final class LinkedQueue<Element> {
    private var head: Node<Element>?     // the front: dequeue here
    private var tail: Node<Element>?     // the back: enqueue here
    private(set) var count = 0

    var isEmpty: Bool { head == nil }

    func enqueue(_ value: Element) {
        let node = Node(value)
        if let tail {
            tail.next = node                 // link it after the current back
        } else {
            head = node                      // empty queue: it's also the front
        }
        tail = node
        count += 1
    }

    func dequeue() -> Element? {
        guard let front = head else { return nil }
        head = front.next
        if head == nil {
            tail = nil                       // that was the last node
        }
        count -= 1
        return front.value
    }

    func peek() -> Element? {
        head?.value
    }

    var values: [Element] {
        var result: [Element] = []
        var node = head
        while let current = node {
            result.append(current.value)
            node = current.next
        }
        return result
    }
}

let queue = LinkedQueue<String>()
queue.enqueue("a")
queue.enqueue("b")
print(queue.values, queue.count)
print(queue.dequeue() ?? "-", queue.dequeue() ?? "-", queue.dequeue() ?? "-")
queue.enqueue("c")
queue.enqueue("d")
print(queue.values, queue.peek() ?? "-")
