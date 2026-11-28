// Generated from src/dsa/content/lessons/queues/queue-two-stacks.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Counts every stack push and pop that the two-stack queue makes
struct CountingQueue {
    var inbox: [Int] = []
    var outbox: [Int] = []
    var stackOperations = 0
    var mostInOneCall = 0

    mutating func enqueue(_ element: Int) {
        inbox.append(element)
        stackOperations += 1
    }

    mutating func dequeue() -> Int? {
        var thisCall = 0
        if outbox.isEmpty {
            while let element = inbox.popLast() {
                outbox.append(element)
                thisCall += 2                 // one pop and one push
            }
        }
        let front = outbox.popLast()
        if front != nil { thisCall += 1 }
        stackOperations += thisCall
        mostInOneCall = max(mostInOneCall, thisCall)
        return front
    }
}

for n in [1_000, 10_000, 100_000] {
    var queue = CountingQueue()
    for value in 1...n {
        queue.enqueue(value)
        if value % 3 != 0 {
            _ = queue.dequeue()               // dequeue after two of every three
        }
    }
    while queue.dequeue() != nil {}           // then drain what's left
    print("\(n) items: \(queue.stackOperations) stack operations, \(queue.stackOperations / n) per item, at most \(queue.mostInOneCall) in one call")
}
