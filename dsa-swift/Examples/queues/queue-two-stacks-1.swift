// Generated from src/dsa/content/lessons/queues/queue-two-stacks.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct TwoStackQueue<Element> {
    private var inbox: [Element] = []     // newest on top (the end)
    private var outbox: [Element] = []    // oldest on top (the end)

    var count: Int { inbox.count + outbox.count }
    var isEmpty: Bool { inbox.isEmpty && outbox.isEmpty }

    mutating func enqueue(_ element: Element) {
        inbox.append(element)
    }

    mutating func dequeue() -> Element? {
        if outbox.isEmpty {
            while let element = inbox.popLast() {
                outbox.append(element)    // pouring reverses the order
            }
        }
        return outbox.popLast()
    }

    func peek() -> Element? {
        outbox.last ?? inbox.first
    }

    var debugState: String { "inbox \(inbox), outbox \(outbox)" }
}

var queue = TwoStackQueue<Int>()
for value in 1...3 { queue.enqueue(value) }
print("enqueue 1, 2, 3 →", queue.debugState)
print("dequeue", queue.dequeue() ?? 0, "→", queue.debugState)
queue.enqueue(4)
print("enqueue 4 →", queue.debugState)
print("peek", queue.peek() ?? 0, "count", queue.count)
print("dequeue", queue.dequeue() ?? 0, "→", queue.debugState)
print("dequeue", queue.dequeue() ?? 0, "→", queue.debugState)
print("dequeue", queue.dequeue() ?? 0, "→", queue.debugState)
