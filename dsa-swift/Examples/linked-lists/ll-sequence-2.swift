// Generated from src/dsa/content/lessons/linked-lists/ll-sequence.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class LinkedList<Element>: Sequence, ExpressibleByArrayLiteral {
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

    init() {}

    convenience init(arrayLiteral elements: Element...) {
        self.init()
        for element in elements {
            append(element)
        }
    }

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

extension LinkedList: CustomStringConvertible {
    var description: String {
        (map { "\($0)" } + ["nil"]).joined(separator: " -> ")
    }
}

let primes: LinkedList = [2, 3, 5, 7]
let words: LinkedList = ["linked", "lists", "rock"]
print(primes)
print(words)
print(words.map { $0.count })
