// Generated from src/dsa/content/lessons/queues/queue-stack-from-queues.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// A minimal queue: the only operations the stack below may use
struct SimpleQueue<Element> {
    private var items: [Element] = []
    private var head = 0

    var count: Int { items.count - head }
    func peek() -> Element? { head < items.count ? items[head] : nil }
    mutating func enqueue(_ element: Element) { items.append(element) }
    mutating func dequeue() -> Element? {
        guard head < items.count else { return nil }
        head += 1
        return items[head - 1]
    }
    var contents: [Element] { Array(items[head...]) }   // front first, for printing
}

struct QueueStack<Element> {
    private var queue = SimpleQueue<Element>()
    private(set) var rotations = 0

    mutating func push(_ element: Element) {
        queue.enqueue(element)
        // Rotate the older items behind the new one, so it reaches the front
        for _ in 0..<(queue.count - 1) {
            queue.enqueue(queue.dequeue()!)
            rotations += 1
        }
    }

    mutating func pop() -> Element? { queue.dequeue() }
    func top() -> Element? { queue.peek() }
    var contents: [Element] { queue.contents }
}

var stack = QueueStack<Int>()
for value in 1...4 {
    stack.push(value)
    print("push \(value): queue front to back \(stack.contents)")
}
print("pop:", stack.pop() ?? 0, "then top:", stack.top() ?? 0)

for n in [10, 100, 1_000] {
    var counted = QueueStack<Int>()
    for value in 0..<n {
        counted.push(value)
    }
    print("\(n) pushes: \(counted.rotations) rotations")
}
