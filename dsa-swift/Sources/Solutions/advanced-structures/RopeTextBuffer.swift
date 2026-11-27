// Reference solution: a persistent implicit treap, one character per node. A node's position is the
// number of characters before it in inorder, found from subtree sizes, so no keys are stored. Split
// cuts the sequence after k characters and merge joins two sequences; both walk one path and, because
// nodes are immutable, copy that path instead of changing it. Insert and delete are two splits and two
// merges: O(log n) expected. Every old root stays valid, so undo pops a stack of earlier roots in O(1),
// and copies of a Buffer are independent for free. Random priorities (from a seeded SplitMix64) keep
// the treap balanced whatever the editing pattern.

public enum RopeTextBuffer {
    final class Node {
        let character: Character
        let priority: UInt64
        let left: Node?
        let right: Node?
        let size: Int

        init(_ character: Character, _ priority: UInt64, left: Node?, right: Node?) {
            self.character = character
            self.priority = priority
            self.left = left
            self.right = right
            size = 1 + (left?.size ?? 0) + (right?.size ?? 0)
        }

        /// A copy with new children: the only way a "change" happens.
        func with(left: Node?, right: Node?) -> Node {
            Node(character, priority, left: left, right: right)
        }
    }

    public struct Buffer {
        private var root: Node?
        private var history: [Node?] = []
        private var state: UInt64 = 0x0123_4567_89AB_CDEF

        public init(_ text: String = "") {
            root = makeTreap(Array(text))
        }

        public var count: Int { root?.size ?? 0 }

        public var text: String {
            var result = ""
            result.reserveCapacity(count)
            func visit(_ node: Node?) {
                guard let node else { return }
                visit(node.left)
                result.append(node.character)
                visit(node.right)
            }
            visit(root)
            return result
        }

        public func character(at index: Int) -> Character {
            precondition(index >= 0 && index < count, "Index \(index) is out of range")
            var node = root!
            var index = index
            while true {
                let leftSize = node.left?.size ?? 0
                if index < leftSize {
                    node = node.left!
                } else if index == leftSize {
                    return node.character
                } else {
                    index -= leftSize + 1
                    node = node.right!
                }
            }
        }

        public func slice(from start: Int, count length: Int) -> String {
            precondition(start >= 0 && length >= 0 && start + length <= count, "Range is out of bounds")
            var result = ""
            // Visit only subtrees that overlap start..<start + length; offset is the position of the
            // first character in `node`'s subtree.
            func visit(_ node: Node?, _ offset: Int) {
                guard let node, offset < start + length, offset + node.size > start else { return }
                let leftSize = node.left?.size ?? 0
                visit(node.left, offset)
                let position = offset + leftSize
                if position >= start && position < start + length {
                    result.append(node.character)
                }
                visit(node.right, position + 1)
            }
            visit(root, 0)
            return result
        }

        public mutating func insert(_ text: String, at index: Int) {
            precondition(index >= 0 && index <= count, "Index \(index) is out of range")
            history.append(root)
            let (before, after) = Self.split(root, index)
            root = Self.merge(Self.merge(before, makeTreap(Array(text))), after)
        }

        public mutating func delete(from start: Int, count length: Int) {
            precondition(start >= 0 && length >= 0 && start + length <= count, "Range is out of bounds")
            history.append(root)
            let (before, rest) = Self.split(root, start)
            let (_, after) = Self.split(rest, length)
            root = Self.merge(before, after)
        }

        @discardableResult
        public mutating func undo() -> Bool {
            guard let previous = history.popLast() else { return false }
            root = previous
            return true
        }

        // MARK: Treap helpers

        private mutating func nextPriority() -> UInt64 {
            state &+= 0x9E37_79B9_7F4A_7C15
            var z = state
            z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
            z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
            return z ^ (z >> 31)
        }

        /// A treap of `characters` in O(n): the Cartesian tree of random priorities, built with a stack.
        private mutating func makeTreap(_ characters: [Character]) -> Node? {
            let n = characters.count
            guard n > 0 else { return nil }
            let priorities = (0..<n).map { _ in nextPriority() }
            var left = Array(repeating: -1, count: n)
            var right = Array(repeating: -1, count: n)
            var stack: [Int] = []
            for i in 0..<n {
                var last = -1
                while let top = stack.last, priorities[top] < priorities[i] {
                    last = stack.removeLast()
                }
                left[i] = last
                if let top = stack.last { right[top] = i }
                stack.append(i)
            }
            func make(_ i: Int) -> Node? {
                i < 0 ? nil : Node(characters[i], priorities[i], left: make(left[i]), right: make(right[i]))
            }
            return make(stack[0])
        }

        /// (the first k characters, the rest), copying only the nodes on one path.
        private static func split(_ node: Node?, _ k: Int) -> (Node?, Node?) {
            guard let node else { return (nil, nil) }
            let leftSize = node.left?.size ?? 0
            if k <= leftSize {
                let (a, b) = split(node.left, k)
                return (a, node.with(left: b, right: node.right))
            }
            let (a, b) = split(node.right, k - leftSize - 1)
            return (node.with(left: node.left, right: a), b)
        }

        /// The characters of `a` followed by those of `b`.
        private static func merge(_ a: Node?, _ b: Node?) -> Node? {
            guard let a else { return b }
            guard let b else { return a }
            if a.priority > b.priority {
                return a.with(left: a.left, right: merge(a.right, b))
            }
            return b.with(left: merge(a, b.left), right: b.right)
        }
    }
}
