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

func cycleEntry(_ head: ListNode?) -> ListNode? {
    var slow = head
    var fast = head
    while let next = fast?.next {
        slow = slow?.next
        fast = next.next
        if let meeting = fast, meeting === slow {
            // Phase 2: one pointer from the head, one from the meeting point, both at speed 1
            var outside = head!
            var inside = meeting
            while outside !== inside {
                outside = outside.next!
                inside = inside.next!
            }
            return outside
        }
    }
    return nil
}

print(cycleEntry(makeList([1, 2, 3, 4, 5, 6], loopingTo: 2))?.value ?? -1)
print(cycleEntry(makeList([1, 2, 3, 4, 5, 6], loopingTo: 0))?.value ?? -1)
print(cycleEntry(makeList([1, 2, 3, 4, 5, 6], loopingTo: 5))?.value ?? -1)
print(cycleEntry(makeList([1, 2, 3, 4, 5, 6]))?.value ?? -1)
