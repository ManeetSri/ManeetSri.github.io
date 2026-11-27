// Generated from src/dsa/content/lessons/linked-lists/ll-build-singly.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class LinkedList<Element> {
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
    private(set) var count = 0

    var isEmpty: Bool { head == nil }
    var first: Element? { head?.value }
    var last: Element? { tail?.value }

    func prepend(_ value: Element) {
        head = Node(value, next: head)
        if tail == nil {
            tail = head
        }
        count += 1
    }

    func append(_ value: Element) {
        let node = Node(value)
        if let tail {
            tail.next = node
        } else {
            head = node
        }
        tail = node
        count += 1
    }

    private func node(at index: Int) -> Node {
        var node = head!
        for _ in 0..<index {
            node = node.next!
        }
        return node
    }

    @discardableResult
    func insert(_ value: Element, at index: Int) -> Bool {
        guard index >= 0 && index <= count else { return false }
        if index == 0 {
            prepend(value)
        } else if index == count {
            append(value)
        } else {
            let before = node(at: index - 1)
            before.next = Node(value, next: before.next)
            count += 1
        }
        return true
    }

    @discardableResult
    func removeFirst() -> Element? {
        guard let first = head else { return nil }
        head = first.next
        if head == nil {
            tail = nil
        }
        count -= 1
        return first.value
    }

    @discardableResult
    func remove(at index: Int) -> Element? {
        guard index >= 0 && index < count else { return nil }
        if index == 0 {
            return removeFirst()
        }
        let before = node(at: index - 1)
        let removed = before.next!
        before.next = removed.next
        if removed === tail {
            tail = before
        }
        count -= 1
        return removed.value
    }

    func value(at index: Int) -> Element? {
        guard index >= 0 && index < count else { return nil }
        return node(at: index).value
    }
}

extension LinkedList where Element: Equatable {
    func firstIndex(of value: Element) -> Int? {
        var index = 0
        var current = head
        while let node = current {
            if node.value == value {
                return index
            }
            index += 1
            current = node.next
        }
        return nil
    }
}

extension LinkedList: CustomStringConvertible {
    var description: String {
        var parts: [String] = []
        var current = head
        while let node = current {
            parts.append("\(node.value)")
            current = node.next
        }
        parts.append("nil")
        return parts.joined(separator: " -> ")
    }
}

let list = LinkedList<Int>()
for value in [10, 20, 30] {
    list.append(value)
}
list.insert(15, at: 1)
list.insert(40, at: 4)
print(list)
print(list.insert(99, at: 9), list.firstIndex(of: 30) ?? -1, list.value(at: 2) ?? -1)

print(list.remove(at: 4) ?? -1, "removed; last is now", list.last ?? -1)
list.append(35)
print(list)

while let value = list.removeFirst() {
    print("took", value, "count", list.count)
}
print(list, list.last == nil)
list.append(1)
print(list, "first", list.first ?? -1, "last", list.last ?? -1)
