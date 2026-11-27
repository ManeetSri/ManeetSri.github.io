// Problem: A linked list in a slot pool (M68 · Index-based nodes vs class nodes)

public enum SlotPoolList {
    /// A doubly linked list of Ints whose nodes live in an array of structs. A node's slot number is its
    /// handle. Removed slots form a free list, threaded through `next`, and are reused most recently freed
    /// first, so the array only grows when every slot is in use.
    ///
    /// Every operation is O(1) (amortised for appends to the array), and there is no ARC traffic: the list
    /// is two arrays' worth of plain integers.
    public struct List {
        private struct Node {
            var value: Int
            var previous: Int
            var next: Int
        }

        private static let none = -1

        private var nodes: [Node] = []
        private var head = none
        private var tail = none
        private var freeHead = none
        public private(set) var count = 0

        public init() {}

        public var slotCount: Int {
            nodes.count
        }

        public var values: [Int] {
            var result: [Int] = []
            result.reserveCapacity(count)
            var current = head
            while current != Self.none {
                result.append(nodes[current].value)
                current = nodes[current].next
            }
            return result
        }

        public var valuesBackward: [Int] {
            var result: [Int] = []
            result.reserveCapacity(count)
            var current = tail
            while current != Self.none {
                result.append(nodes[current].value)
                current = nodes[current].previous
            }
            return result
        }

        public func value(at handle: Int) -> Int {
            nodes[handle].value
        }

        /// Takes a slot from the free list, or adds a new one, and fills it
        private mutating func makeNode(_ value: Int, previous: Int, next: Int) -> Int {
            let node = Node(value: value, previous: previous, next: next)
            if freeHead != Self.none {
                let slot = freeHead
                freeHead = nodes[slot].next
                nodes[slot] = node
                return slot
            }
            nodes.append(node)
            return nodes.count - 1
        }

        @discardableResult
        public mutating func pushFront(_ value: Int) -> Int {
            let slot = makeNode(value, previous: Self.none, next: head)
            if head != Self.none {
                nodes[head].previous = slot
            } else {
                tail = slot
            }
            head = slot
            count += 1
            return slot
        }

        @discardableResult
        public mutating func pushBack(_ value: Int) -> Int {
            if tail == Self.none {
                return pushFront(value)
            }
            return insert(value, after: tail)
        }

        @discardableResult
        public mutating func insert(_ value: Int, after handle: Int) -> Int {
            let following = nodes[handle].next
            let slot = makeNode(value, previous: handle, next: following)
            nodes[handle].next = slot
            if following != Self.none {
                nodes[following].previous = slot
            } else {
                tail = slot
            }
            count += 1
            return slot
        }

        @discardableResult
        public mutating func remove(_ handle: Int) -> Int {
            let node = nodes[handle]
            if node.previous != Self.none {
                nodes[node.previous].next = node.next
            } else {
                head = node.next
            }
            if node.next != Self.none {
                nodes[node.next].previous = node.previous
            } else {
                tail = node.previous
            }
            // Push the slot onto the free list
            nodes[handle].next = freeHead
            nodes[handle].previous = Self.none
            freeHead = handle
            count -= 1
            return node.value
        }
    }
}
