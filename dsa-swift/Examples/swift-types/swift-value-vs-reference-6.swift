// Generated from src/dsa/content/lessons/swift-types/swift-value-vs-reference.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class Node {
    var value: Int
    var next: Node?

    init(value: Int, next: Node? = nil) {
        self.value = value
        self.next = next
    }
}

let third = Node(value: 30)
let second = Node(value: 20, next: third)
let head = Node(value: 10, next: second)

var current: Node? = head
while let node = current {
    print(node.value)
    current = node.next
}

second.value = 25
print("Through head:", head.next!.value)
