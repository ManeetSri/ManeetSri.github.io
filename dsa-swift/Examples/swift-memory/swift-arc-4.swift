// Generated from src/dsa/content/lessons/swift-memory/swift-arc.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class Node {
    let value: Int
    var next: Node?

    init(_ value: Int, next: Node? = nil) {
        self.value = value
        self.next = next
    }

    deinit {
        print("node \(value) freed")
    }
}

var head: Node? = Node(1, next: Node(2, next: Node(3)))
print("remove the first node")
head = head?.next
print("head is now \(head!.value)")
print("clear the list")
head = nil
print("done")
