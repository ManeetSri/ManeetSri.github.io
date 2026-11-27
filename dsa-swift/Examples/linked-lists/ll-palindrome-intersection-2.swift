// Generated from src/dsa/content/lessons/linked-lists/ll-palindrome-intersection.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class ListNode {
    var value: Int
    var next: ListNode?

    init(_ value: Int, next: ListNode? = nil) {
        self.value = value
        self.next = next
    }
}

func intersection(_ a: ListNode?, _ b: ListNode?) -> ListNode? {
    var p = a
    var q = b
    while p !== q {
        p = (p == nil) ? b : p?.next
        q = (q == nil) ? a : q?.next
    }
    return p
}

// Build the Y: A = 4 -> 1 -> [8 -> 5 -> 2], B = 6 -> 0 -> 3 -> [8 -> 5 -> 2]
let shared = ListNode(8, next: ListNode(5, next: ListNode(2)))
let a = ListNode(4, next: ListNode(1, next: shared))
let b = ListNode(6, next: ListNode(0, next: ListNode(3, next: shared)))

let meet = intersection(a, b)
print(meet?.value ?? -1, meet === shared)

// Same values, but separate nodes: no intersection
let c = ListNode(8, next: ListNode(5, next: ListNode(2)))
print(intersection(a, c)?.value ?? -1)
print(intersection(a, a)?.value ?? -1)
