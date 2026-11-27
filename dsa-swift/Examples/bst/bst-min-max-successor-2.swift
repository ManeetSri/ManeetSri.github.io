// Generated from src/dsa/content/lessons/bst/bst-min-max-successor.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class Node {
    var value: Int
    var left: Node?
    var right: Node?
    weak var parent: Node?                     // weak: the parent already owns this node

    init(_ value: Int) {
        self.value = value
    }
}

func insert(_ value: Int, into root: Node?) -> Node {
    let fresh = Node(value)
    guard let root else { return fresh }
    var node = root
    while true {
        if value < node.value {
            guard let left = node.left else { node.left = fresh; break }
            node = left
        } else {                               // bigger (this example has no repeats)
            guard let right = node.right else { node.right = fresh; break }
            node = right
        }
    }
    fresh.parent = node
    return root
}

func successor(of node: Node) -> Node? {
    if var next = node.right {                 // case 1: the minimum of the right subtree
        while let left = next.left {
            next = left
        }
        return next
    }
    var child = node                           // case 2: climb until we come up from a left child
    while let parent = child.parent {
        if parent.left === child {
            return parent
        }
        child = parent
    }
    return nil                                 // we were the maximum
}

func find(_ value: Int, in root: Node) -> Node? {
    var current: Node? = root
    while let node = current, node.value != value {
        current = value < node.value ? node.left : node.right
    }
    return current
}

var root: Node? = nil
for value in [50, 30, 70, 20, 40, 60, 80, 35, 65] {
    root = insert(value, into: root)
}
for value in [30, 40, 65, 80] {
    let next = successor(of: find(value, in: root!)!)
    print("after \(value):", next.map { String($0.value) } ?? "none")
}
