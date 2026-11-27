// Generated from src/dsa/content/lessons/linked-lists/ll-doubly-circular.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class DNode {
    var value: Int
    var next: DNode?
    weak var previous: DNode?

    init(_ value: Int) {
        self.value = value
    }
}

final class DoublyLinkedList {
    private let head = DNode(0)        // sentinel before the first real node
    private let tail = DNode(0)        // sentinel after the last real node

    init() {
        head.next = tail
        tail.previous = head
    }

    /// Links a new node in straight after `node` and returns it. O(1).
    @discardableResult
    func insert(_ value: Int, after node: DNode) -> DNode {
        let fresh = DNode(value)
        let following = node.next!
        fresh.previous = node
        fresh.next = following
        node.next = fresh
        following.previous = fresh
        return fresh
    }

    @discardableResult
    func pushFront(_ value: Int) -> DNode {
        insert(value, after: head)
    }

    @discardableResult
    func pushBack(_ value: Int) -> DNode {
        insert(value, after: tail.previous!)
    }

    /// Unlinks a real node by joining its neighbours. O(1).
    func remove(_ node: DNode) {
        let before = node.previous!
        let after = node.next!
        before.next = after
        after.previous = before
        node.next = nil
        node.previous = nil
    }

    var forwards: [Int] {
        var result: [Int] = []
        var current = head.next!
        while current !== tail {
            result.append(current.value)
            current = current.next!
        }
        return result
    }

    var backwards: [Int] {
        var result: [Int] = []
        var current = tail.previous!
        while current !== head {
            result.append(current.value)
            current = current.previous!
        }
        return result
    }
}

let list = DoublyLinkedList()
list.pushBack(1)
let two = list.pushBack(2)
list.pushBack(3)
list.pushFront(0)
print(list.forwards, list.backwards)

list.remove(two)                      // O(1): no search for the node before it
print(list.forwards)

list.insert(9, after: list.pushFront(-1))
print(list.forwards, list.backwards)
