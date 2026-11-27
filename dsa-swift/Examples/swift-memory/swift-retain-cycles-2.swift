// Generated from src/dsa/content/lessons/swift-memory/swift-retain-cycles.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class Node {
    static var alive = 0
    var next: Node?

    init() { Node.alive += 1 }
    deinit { Node.alive -= 1 }
}

for _ in 1...3 {
    let a = Node()
    let b = Node()
    a.next = b
    b.next = a
}
print("nodes alive after the cycles: \(Node.alive)")

for _ in 1...3 {
    let a = Node()
    let b = Node()
    a.next = b
}
print("nodes alive after the chains: \(Node.alive)")
