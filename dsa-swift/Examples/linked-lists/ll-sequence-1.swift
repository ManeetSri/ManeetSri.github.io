// Generated from src/dsa/content/lessons/linked-lists/ll-sequence.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class LinkedList<Element>: Sequence {
    final class Node {
        var value: Element
        var next: Node?

        init(_ value: Element, next: Node? = nil) {
            self.value = value
            self.next = next
        }
    }

    private var head: Node?
    private var tail: Node?

    func append(_ value: Element) {
        let node = Node(value)
        if let tail {
            tail.next = node
        } else {
            head = node
        }
        tail = node
    }

    struct Iterator: IteratorProtocol {
        var current: Node?

        mutating func next() -> Element? {
            guard let node = current else {
                return nil
            }
            current = node.next
            return node.value
        }
    }

    func makeIterator() -> Iterator {
        Iterator(current: head)
    }
}

let scores = LinkedList<Int>()
for score in [72, 95, 58, 88] {
    scores.append(score)
}

for score in scores {
    print(score, terminator: " ")
}
print()
print(Array(scores))
print(scores.map { $0 + 5 })
print(scores.filter { $0 >= 70 })
print(scores.reduce(0, +), scores.max() ?? 0, scores.contains(58))
for (place, score) in scores.sorted(by: >).enumerated() where place < 2 {
    print(place + 1, score)
}
