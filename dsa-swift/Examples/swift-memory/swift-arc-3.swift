// Generated from src/dsa/content/lessons/swift-memory/swift-arc.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class Ticket {
    let id: Int
    init(id: Int) { self.id = id }
    deinit { print("ticket \(id) freed") }
}

final class Queue {
    var waiting: [Ticket] = []
}

do {
    let queue = Queue()
    queue.waiting.append(Ticket(id: 7))
    print("ticket stored")
    queue.waiting.removeAll()
    print("queue emptied")
}
