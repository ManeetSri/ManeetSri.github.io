// Generated from src/dsa/content/lessons/queues/queue-head-index.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct IndexQueue {
    var items: [Int] = []
    var head = 0
    var count: Int { items.count - head }

    mutating func enqueue(_ element: Int) { items.append(element) }

    mutating func dequeue() -> Int? {
        guard head < items.count else { return nil }
        let element = items[head]
        head += 1
        return element
    }
}

var queue = IndexQueue()
for ticket in 1...3 { queue.enqueue(ticket) }
// A busy counter: one customer joins and one is served, 1,000 times over
for ticket in 4...1_003 {
    queue.enqueue(ticket)
    _ = queue.dequeue()
}
print("waiting:", queue.count)
print("slots in the array:", queue.items.count)
print("dead slots:", queue.head)
