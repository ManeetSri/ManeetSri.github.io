// Generated from src/dsa/content/lessons/swift-generics/swift-sequence-iterator.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let tripling = sequence(first: 1) { $0 * 3 }
print(Array(tripling.prefix(while: { $0 < 100 })))

final class Node {
    let value: Int
    var next: Node?

    init(_ value: Int, next: Node? = nil) {
        self.value = value
        self.next = next
    }
}

let head = Node(1, next: Node(2, next: Node(3)))
let values = sequence(first: head) { $0.next }.map { $0.value }
print(values)
