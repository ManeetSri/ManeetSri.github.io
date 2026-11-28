// Generated from src/dsa/content/lessons/queues/queue-head-index.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct CompactingQueue {
    var items: [Int] = []
    var head = 0
    var moves = 0                  // elements moved by compaction, for counting
    var compactions = 0

    var count: Int { items.count - head }

    mutating func enqueue(_ element: Int) { items.append(element) }

    mutating func dequeue() -> Int? {
        guard head < items.count else { return nil }
        let element = items[head]
        head += 1
        if head == items.count {
            items.removeAll(keepingCapacity: true)   // empty: start afresh, for free
            head = 0
        } else if head >= 16 && head * 2 >= items.count {
            moves += items.count - head              // the live elements move to the front
            compactions += 1
            items.removeFirst(head)
            head = 0
        }
        return element
    }
}

for waiting in [3, 100, 5_000] {
    var queue = CompactingQueue()
    for ticket in 0..<waiting { queue.enqueue(ticket) }
    var largest = 0
    var ticket = waiting
    for _ in 0..<100_000 {
        queue.enqueue(ticket)
        ticket += 1
        _ = queue.dequeue()
        largest = max(largest, queue.items.count)
    }
    print("\(waiting) waiting: largest array \(largest), \(queue.moves) moves, removeFirst would move \(waiting * 100_000)")
}
