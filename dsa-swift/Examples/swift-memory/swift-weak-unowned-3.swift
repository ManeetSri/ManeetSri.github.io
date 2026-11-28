// Generated from src/dsa/content/lessons/swift-memory/swift-weak-unowned.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class ListNode {
    let value: Int
    var next: ListNode?
    weak var previous: ListNode?

    init(_ value: Int) { self.value = value }
    deinit { print("freed \(value)") }
}

func makeList(_ values: [Int]) -> ListNode? {
    var head: ListNode? = nil
    var tail: ListNode? = nil
    for value in values {
        let node = ListNode(value)
        if let tail {
            tail.next = node
            node.previous = tail
        } else {
            head = node
        }
        tail = node
    }
    return head
}

var head = makeList([1, 2, 3])

// Walk forwards to the last node, then backwards using previous
var node = head
while let next = node?.next {
    node = next
}
var backwards: [Int] = []
while let current = node {
    backwards.append(current.value)
    node = current.previous
}
print(backwards)

head = nil
print("list cleared")
