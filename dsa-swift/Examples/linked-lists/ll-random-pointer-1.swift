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

func copyWithDictionary(_ head: Node?) -> Node? {
    var copies: [ObjectIdentifier: Node] = [:]

    // Pass 1: a copy of every node, filed under its original's identity
    var current = head
    while let node = current {
        copies[ObjectIdentifier(node)] = Node(node.value)
        current = node.next
    }

    // Pass 2: wire up next and random between the copies
    current = head
    while let node = current {
        let copy = copies[ObjectIdentifier(node)]!
        copy.next = node.next.flatMap { copies[ObjectIdentifier($0)] }
        copy.random = node.random.flatMap { copies[ObjectIdentifier($0)] }
        current = node.next
    }

    return head.flatMap { copies[ObjectIdentifier($0)] }
}

let original = makeList([7, 13, 11, 10, 1], randoms: [nil, 0, 4, 2, 0])
let copy = copyWithDictionary(original)
print(describe(original))
print(describe(copy))

// Is it a deep copy? No node of the copy may be a node of the original.
var originals = Set<ObjectIdentifier>()
var walker = original
while let node = walker {
    originals.insert(ObjectIdentifier(node))
    walker = node.next
}
var shared = 0
walker = copy
while let node = walker {
    if originals.contains(ObjectIdentifier(node)) { shared += 1 }
    if let target = node.random, originals.contains(ObjectIdentifier(target)) { shared += 1 }
    walker = node.next
}
print("references into the original:", shared)
