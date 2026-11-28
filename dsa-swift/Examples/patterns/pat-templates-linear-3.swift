// Generated from src/dsa/content/lessons/patterns/pat-templates-linear.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Fast and slow pointers on a linked list
final class Node {
    let value: Int
    var next: Node?
    init(_ value: Int) { self.value = value }
}

func makeList(_ values: [Int]) -> Node? {
    let dummy = Node(0)
    var tail = dummy
    for value in values {
        tail.next = Node(value)
        tail = tail.next!
    }
    return dummy.next
}

func middle(_ head: Node?) -> Node? {
    var slow = head
    var fast = head
    while let next = fast?.next {                 // fast can take two steps
        slow = slow?.next
        fast = next.next
    }
    return slow                                   // the second middle for even lengths
}

func hasCycle(_ head: Node?) -> Bool {
    var slow = head
    var fast = head
    while let next = fast?.next {
        slow = slow?.next
        fast = next.next
        if slow === fast { return true }          // identity, not equal values
    }
    return false
}

print(middle(makeList([1, 2, 3, 4, 5]))!.value)
print(middle(makeList([1, 2, 3, 4, 5, 6]))!.value)
let looped = makeList([1, 2, 3, 4])
looped!.next!.next!.next!.next = looped!.next     // 4 points back to 2
print(hasCycle(looped), hasCycle(makeList([1, 2, 3])))
