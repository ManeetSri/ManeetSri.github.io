// Generated from src/dsa/content/lessons/bst/bst-generic.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct SearchTree<Element: Comparable> {
    final class Node {
        var value: Element
        var left: Node?
        var right: Node?
        init(_ value: Element) { self.value = value }
    }

    final class Storage {
        var root: Node?
        var count = 0

        func copy() -> Storage {
            let result = Storage()
            result.count = count
            guard let root else { return result }
            let rootCopy = Node(root.value)
            result.root = rootCopy
            var pending = [(root, rootCopy)]
            while let (original, copy) = pending.popLast() {
                if let left = original.left {
                    copy.left = Node(left.value)
                    pending.append((left, copy.left!))
                }
                if let right = original.right {
                    copy.right = Node(right.value)
                    pending.append((right, copy.right!))
                }
            }
            return result
        }
    }

    private var storage = Storage()

    var count: Int { storage.count }

    @discardableResult
    mutating func insert(_ element: Element) -> Bool {
        if !isKnownUniquelyReferenced(&storage) {
            print("  (copying \(storage.count) nodes first)")
            storage = storage.copy()
        }
        guard var node = storage.root else {
            storage.root = Node(element)
            storage.count = 1
            return true
        }
        while true {
            if element < node.value {
                guard let left = node.left else { node.left = Node(element); break }
                node = left
            } else if node.value < element {
                guard let right = node.right else { node.right = Node(element); break }
                node = right
            } else {
                return false
            }
        }
        storage.count += 1
        return true
    }
}

extension SearchTree: Sequence {
    struct Iterator: IteratorProtocol {
        let storage: Storage
        var stack: [Node] = []

        init(_ storage: Storage) {
            self.storage = storage
            pushLeftSpine(from: storage.root)
        }

        mutating func pushLeftSpine(from start: Node?) {
            var current = start
            while let node = current {
                stack.append(node)
                current = node.left
            }
        }

        mutating func next() -> Element? {
            guard let node = stack.popLast() else { return nil }
            pushLeftSpine(from: node.right)
            return node.value
        }
    }

    func makeIterator() -> Iterator { Iterator(storage) }
}

var fruit = SearchTree<String>()
for name in ["pear", "fig", "apple", "kiwi", "fig"] {
    fruit.insert(name)
}
print(Array(fruit), fruit.count)

var copy = fruit                       // shares the nodes: O(1)
copy.insert("banana")                  // shared, so it copies first
copy.insert("cherry")                  // now unique: no copy
print(Array(fruit))
print(Array(copy))

var numbers = SearchTree<Int>()
for n in [5, 2, 8] { numbers.insert(n) }
for n in numbers {
    numbers.insert(n * 10)             // the loop keeps walking the original nodes
}
print(Array(numbers))
print(numbers.map { $0 + 1 }.prefix(3), numbers.contains(80))
