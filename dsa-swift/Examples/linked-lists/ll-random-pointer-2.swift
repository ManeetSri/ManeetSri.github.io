// Generated from src/dsa/content/lessons/linked-lists/ll-random-pointer.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class Node {
    var value: Int
    var next: Node?
    weak var random: Node?

    init(_ value: Int) {
        self.value = value
    }
}

func makeList(_ values: [Int], randoms: [Int?]) -> Node? {
    let nodes = values.map { Node($0) }
    for i in nodes.indices {
        if i + 1 < nodes.count {
            nodes[i].next = nodes[i + 1]
        }
        if let target = randoms[i] {
            nodes[i].random = nodes[target]
        }
    }
    return nodes.first
}

func describe(_ head: Node?) -> String {
    var parts: [String] = []
    var current = head
    while let node = current {
        let target = node.random.map { String($0.value) } ?? "nil"
        parts.append("\(node.value)(r:\(target))")
        current = node.next
    }
    parts.append("nil")
    return parts.joined(separator: " -> ")
}

func copyByWeaving(_ head: Node?) -> Node? {
    guard let head else { return nil }

    // 1. Weave: original, copy, original, copy, ...
    var current: Node? = head
    while let node = current {
        let copy = Node(node.value)
        copy.next = node.next
        node.next = copy
        current = copy.next
    }

    // 2. Each copy's random is the copy of its original's random: the node right after it
    current = head
    while let node = current {
        let copy = node.next!
        copy.random = node.random?.next
        current = copy.next
    }

    // 3. Unweave into two separate lists
    let copyHead = head.next!
    current = head
    while let node = current {
        let copy = node.next!
        node.next = copy.next               // the original skips its copy
        copy.next = copy.next?.next         // the copy skips the next original
        current = node.next
    }
    return copyHead
}

let original = makeList([7, 13, 11, 10, 1], randoms: [nil, 0, 4, 2, 0])
let copy = copyByWeaving(original)
print(describe(original))
print(describe(copy))
print(copy === original, copy!.next!.random === original)
print(describe(copyByWeaving(makeList([5], randoms: [0]))))
