// Generated from src/dsa/content/lessons/linked-lists/ll-persistent.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class PNode {
    let value: Int
    let next: PNode?

    init(_ value: Int, next: PNode?) {
        self.value = value
        self.next = next
    }
}

func describe(_ head: PNode?) -> String {
    var parts: [String] = []
    var current = head
    while let node = current {
        parts.append(String(node.value))
        current = node.next
    }
    parts.append("nil")
    return parts.joined(separator: " -> ")
}

/// A new version with the value at `index` replaced. Copies the nodes before it and shares the rest.
func replacing(_ head: PNode?, at index: Int, with value: Int) -> PNode? {
    guard let head else { return nil }
    if index == 0 {
        return PNode(value, next: head.next)                    // share everything after
    }
    return PNode(head.value, next: replacing(head.next, at: index - 1, with: value))
}

let original = PNode(1, next: PNode(2, next: PNode(3, next: PNode(4, next: nil))))
let edited = replacing(original, at: 1, with: 20)

print(describe(original))
print(describe(edited))
print("first node shared?", edited === original)
print("tail from 3 shared?", edited?.next?.next === original.next?.next)
