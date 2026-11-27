// Generated from src/dsa/content/lessons/swift-memory/swift-retain-cycles.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class Node {
    let name: String
    var next: Node?

    init(_ name: String) {
        self.name = name
        print("\(name) created")
    }

    deinit {
        print("\(name) freed")
    }
}

do {
    let a = Node("A")
    let b = Node("B")
    a.next = b
    b.next = a
    print("leaving the scope")
}
print("scope ended")
