// Generated from src/dsa/content/lessons/balanced-trees/bal-ordered-map.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// A sorted map: an AVL tree of key-value nodes inside a struct, with copy-on-write
struct SortedMap<Key: Comparable, Value> {
    final class Node {
        let key: Key
        var value: Value
        var left: Node?
        var right: Node?
        var height = 1

        init(_ key: Key, _ value: Value) {
            self.key = key
            self.value = value
        }

        // A deep copy. The recursion is only as deep as the tree: O(log n).
        func copy() -> Node {
            let node = Node(key, value)
            node.height = height
            node.left = left?.copy()
            node.right = right?.copy()
            return node
        }
    }

    private var root: Node?
    private(set) var count = 0

    // MARK: Lookups (no changes, so no copying)

    subscript(key: Key) -> Value? {
        get {
            var current = root
            while let node = current {
                if key < node.key { current = node.left }
                else if node.key < key { current = node.right }
                else { return node.value }
            }
            return nil
        }
        set {
            guard let newValue else { return }       // removal is left out to keep this short
            if !isKnownUniquelyReferenced(&root) {
                root = root?.copy()                  // another copy shares these nodes: copy first
            }
            var inserted = false
            root = Self.insert(key, newValue, into: root, inserted: &inserted)
            if inserted { count += 1 }
        }
    }

    // The entry with the largest key ≤ key
    func floor(_ key: Key) -> (key: Key, value: Value)? {
        var best: Node?
        var current = root
        while let node = current {
            if node.key <= key {
                best = node                          // a candidate; anything better is to the right
                current = node.right
            } else {
                current = node.left
            }
        }
        return best.map { ($0.key, $0.value) }
    }

    // The entry with the smallest key ≥ key
    func ceiling(_ key: Key) -> (key: Key, value: Value)? {
        var best: Node?
        var current = root
        while let node = current {
            if node.key >= key {
                best = node                          // a candidate; anything better is to the left
                current = node.left
            } else {
                current = node.right
            }
        }
        return best.map { ($0.key, $0.value) }
    }

    // The entries with keys in range, in order: O(log n + k) for k results
    func elements(in range: ClosedRange<Key>) -> [(key: Key, value: Value)] {
        var result: [(key: Key, value: Value)] = []
        func visit(_ node: Node?) {
            guard let node else { return }
            if range.lowerBound < node.key { visit(node.left) }      // smaller keys may be in range
            if range.contains(node.key) { result.append((node.key, node.value)) }
            if node.key < range.upperBound { visit(node.right) }     // larger keys may be in range
        }
        visit(root)
        return result
    }

    // MARK: AVL insert, as in the AVL lesson

    private static func height(_ node: Node?) -> Int { node?.height ?? 0 }

    private static func update(_ node: Node) {
        node.height = 1 + Swift.max(height(node.left), height(node.right))   // not the Sequence method
    }

    private static func rotateRight(_ y: Node) -> Node {
        let x = y.left!
        y.left = x.right
        x.right = y
        update(y)
        update(x)
        return x
    }

    private static func rotateLeft(_ x: Node) -> Node {
        let y = x.right!
        x.right = y.left
        y.left = x
        update(x)
        update(y)
        return y
    }

    private static func rebalance(_ node: Node) -> Node {
        update(node)
        let balance = height(node.left) - height(node.right)
        if balance > 1 {
            if height(node.left!.left) < height(node.left!.right) { node.left = rotateLeft(node.left!) }
            return rotateRight(node)
        }
        if balance < -1 {
            if height(node.right!.right) < height(node.right!.left) { node.right = rotateRight(node.right!) }
            return rotateLeft(node)
        }
        return node
    }

    private static func insert(_ key: Key, _ value: Value, into node: Node?, inserted: inout Bool) -> Node {
        guard let node else {
            inserted = true
            return Node(key, value)
        }
        if key < node.key {
            node.left = insert(key, value, into: node.left, inserted: &inserted)
        } else if node.key < key {
            node.right = insert(key, value, into: node.right, inserted: &inserted)
        } else {
            node.value = value                       // an existing key: overwrite its value
            return node
        }
        return rebalance(node)
    }
}

// Iterating visits the entries in key order, with an explicit stack instead of recursion
extension SortedMap: Sequence {
    struct Iterator: IteratorProtocol {
        let root: Node?                              // keeps the nodes shared, so changes copy them
        var stack: [Node] = []

        init(root: Node?) {
            self.root = root
            pushLeftEdge(root)
        }

        mutating func pushLeftEdge(_ start: Node?) {
            var current = start
            while let node = current {
                stack.append(node)
                current = node.left
            }
        }

        mutating func next() -> (key: Key, value: Value)? {
            guard let node = stack.popLast() else { return nil }
            pushLeftEdge(node.right)                 // everything after node, smallest first
            return (node.key, node.value)
        }
    }

    func makeIterator() -> Iterator {
        Iterator(root: root)
    }
}

var prices = SortedMap<Int, Double>()            // minute of the day → share price
for (minute, price) in [(540, 101.5), (600, 99.0), (570, 100.25), (660, 102.0), (630, 98.75)] {
    prices[minute] = price
}
print("count:", prices.count, "keys:", prices.map { $0.key })
print("price in force at 615:", prices.floor(615)!.value)
print("first quote at or after 615:", prices.ceiling(615)!.key)
print("between 560 and 640:", prices.elements(in: 560...640).map { $0.key })
print("before 9:00?", prices.floor(539) == nil)

var corrected = prices                           // a copy: shares the nodes for now
corrected[600] = 99.5
print("original 600:", prices[600]!, "corrected 600:", corrected[600]!)
