// Generated from src/dsa/content/lessons/linked-lists/ll-fast-slow.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class ListNode {
    var value: Int
    var next: ListNode?

    init(_ value: Int, next: ListNode? = nil) {
        self.value = value
        self.next = next
    }
}

/// Builds a list whose last node points back at the node at `index`, or ends in nil.
func makeList(_ values: [Int], loopingTo index: Int? = nil) -> ListNode? {
    let nodes = values.map { ListNode($0) }
    for i in nodes.indices.dropLast() {
        nodes[i].next = nodes[i + 1]
    }
    if let index {
        nodes.last?.next = nodes[index]
    }
    return nodes.first
}

func hasCycle(_ head: ListNode?) -> Bool {
    var slow = head
    var fast = head
    while let next = fast?.next {
        slow = slow?.next
        fast = next.next
        if fast != nil && fast === slow {
            return true
        }
    }
    return false
}

let looped = makeList([1, 2, 3, 4, 5, 6], loopingTo: 2)
print(hasCycle(looped))
print(hasCycle(makeList([1, 2, 3, 4, 5, 6])))
print(hasCycle(makeList([7], loopingTo: 0)))
print(hasCycle(nil))

looped?.next?.next?.next?.next?.next?.next = nil   // break the loop so ARC can free it
