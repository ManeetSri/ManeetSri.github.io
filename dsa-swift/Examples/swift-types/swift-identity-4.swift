// Generated from src/dsa/content/lessons/swift-types/swift-identity.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class Node {
    let value: Int
    var next: Node?

    init(value: Int) {
        self.value = value
    }
}

let a = Node(value: 1)
let b = Node(value: 2)
let c = Node(value: 3)
a.next = b
b.next = c
c.next = a

var current = a
repeat {
    print(current.value)
    current = current.next!
} while current !== a
print("Back at the start")
