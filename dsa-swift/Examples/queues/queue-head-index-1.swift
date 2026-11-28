// Generated from src/dsa/content/lessons/queues/queue-head-index.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct IndexQueue<Element> {
    private var items: [Element] = []
    private var head = 0           // the position of the front element

    var count: Int { items.count - head }
    var isEmpty: Bool { head == items.count }

    mutating func enqueue(_ element: Element) {
        items.append(element)
    }

    mutating func dequeue() -> Element? {
        guard head < items.count else { return nil }
        let element = items[head]
        head += 1                  // nothing moves: the front is now one place on
        return element
    }

    func peek() -> Element? {
        head < items.count ? items[head] : nil
    }

    var debugState: String { "items \(items), head \(head)" }
}

var queue = IndexQueue<String>()
queue.enqueue("Ana")
queue.enqueue("Ben")
queue.enqueue("Cleo")
print(queue.debugState)
print(queue.dequeue() ?? "-", "|", queue.debugState)
queue.enqueue("Dev")
print(queue.dequeue() ?? "-", "|", queue.debugState)
print("peek:", queue.peek() ?? "-", "count:", queue.count)
