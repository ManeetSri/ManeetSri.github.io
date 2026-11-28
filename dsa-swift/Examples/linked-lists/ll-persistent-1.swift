// Generated from src/dsa/content/lessons/linked-lists/ll-persistent.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct LinkedList<Element>: Sequence {
    final class Node {
        var value: Element
        var next: Node?
        init(_ value: Element) { self.value = value }
    }

    final class Storage {
        var head: Node?
        var tail: Node?
        var count = 0

        func copy() -> Storage {
            print("  (copying \(count) nodes)")
            let result = Storage()
            var current = head
            while let node = current {
                result.append(node.value)
                current = node.next
            }
            return result
        }

        func append(_ value: Element) {
            let node = Node(value)
            if let tail { tail.next = node } else { head = node }
            tail = node
            count += 1
        }
    }

    private var storage = Storage()

    private mutating func makeUnique() {
        if !isKnownUniquelyReferenced(&storage) {
            storage = storage.copy()
        }
    }

    mutating func append(_ value: Element) {
        makeUnique()
        storage.append(value)
    }

    struct Iterator: IteratorProtocol {
        let storage: Storage           // keeps the storage alive and shared during a loop
        var current: Node?

        mutating func next() -> Element? {
            guard let node = current else { return nil }
            current = node.next
            return node.value
        }
    }

    func makeIterator() -> Iterator {
        Iterator(storage: storage, current: storage.head)
    }
}

var a = LinkedList<Int>()
a.append(1)
a.append(2)
var b = a                          // O(1): a and b share the nodes
print("b.append(3)")
b.append(3)                        // first write to shared storage: copy, then append
print("b.append(4)")
b.append(4)                        // b's storage is unique now: no copy
print(Array(a), Array(b))

print("looping over a while appending to it")
for value in a {
    a.append(value * 10)
}
print(Array(a))
