// Generated from src/dsa/content/lessons/swift-types/swift-classes.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

class Ticket {
    let id: Int

    init(id: Int) {
        self.id = id
        print("Ticket \(id) created")
    }

    deinit {
        print("Ticket \(id) destroyed")
    }
}

var current: Ticket? = Ticket(id: 1)
current = nil
print("After setting to nil")

do {
    let first = Ticket(id: 2)
    let second = Ticket(id: 3)
    print("Using tickets \(first.id) and \(second.id)")
}
print("After the do block")
