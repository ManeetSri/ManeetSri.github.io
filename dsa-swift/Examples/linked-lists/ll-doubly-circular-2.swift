// Generated from src/dsa/content/lessons/linked-lists/ll-doubly-circular.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class ListNode {
    var value: Int
    var next: ListNode?

    init(_ value: Int, next: ListNode? = nil) {
        self.value = value
        self.next = next
    }
}

func josephus(people n: Int, every k: Int) -> (order: [Int], survivor: Int) {
    // Build the circle 1 -> 2 -> ... -> n -> back to 1
    let first = ListNode(1)
    var last = first
    for value in stride(from: 2, through: n, by: 1) {
        last.next = ListNode(value)
        last = last.next!
    }
    last.next = first

    var order: [Int] = []
    var before = last                      // the node just before the next person counted
    while before.next !== before {         // more than one person left
        for _ in 0..<(k - 1) {
            before = before.next!
        }
        let leaving = before.next!
        order.append(leaving.value)
        before.next = leaving.next         // close the circle over the gap
    }
    let survivor = before.value
    before.next = nil                      // break the final loop so ARC can free the node
    return (order, survivor)
}

let result = josephus(people: 7, every: 3)
print(result.order, result.survivor)
print(josephus(people: 5, every: 2).survivor)
print(josephus(people: 1, every: 4).survivor)
