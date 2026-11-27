// Generated from src/dsa/content/lessons/balanced-trees/bal-splay.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class Node {
    let key: Int
    var left: Node?
    var right: Node?
    init(_ key: Int) { self.key = key }
}

var rotations = 0

func rotateRight(_ y: Node) -> Node {
    rotations += 1
    let x = y.left!
    y.left = x.right
    x.right = y
    return x
}

func rotateLeft(_ x: Node) -> Node {
    rotations += 1
    let y = x.right!
    x.right = y.left
    y.left = x
    return y
}

// Brings key to the root if it's in the tree; otherwise the last node on its search path.
// Each call handles two levels: a zig-zig or a zig-zag, or a final zig.
func splay(_ root: Node?, _ key: Int) -> Node? {
    guard let root, root.key != key else { return root }
    if key < root.key {
        guard let child = root.left else { return root }           // not found: stop here
        if key < child.key {                                       // zig-zig (left-left)
            child.left = splay(child.left, key)
            let lifted = rotateRight(root)                         // grandparent first…
            return lifted.left == nil ? lifted : rotateRight(lifted)   // …then parent
        } else if key > child.key {                                // zig-zag (left-right)
            child.right = splay(child.right, key)
            if child.right != nil { root.left = rotateLeft(child) }
            return root.left == nil ? root : rotateRight(root)
        }
        return rotateRight(root)                                   // zig: child holds key
    } else {
        guard let child = root.right else { return root }
        if key > child.key {                                       // zig-zig (right-right)
            child.right = splay(child.right, key)
            let lifted = rotateLeft(root)
            return lifted.right == nil ? lifted : rotateLeft(lifted)
        } else if key < child.key {                                // zig-zag (right-left)
            child.left = splay(child.left, key)
            if child.left != nil { root.right = rotateRight(child) }
            return root.right == nil ? root : rotateLeft(root)
        }
        return rotateLeft(root)
    }
}

// The naive alternative: rotate key up one level at a time, always at its parent
func moveToRoot(_ root: Node?, _ key: Int) -> Node? {
    guard let root, root.key != key else { return root }
    if key < root.key {
        guard root.left != nil else { return root }
        root.left = moveToRoot(root.left, key)
        return rotateRight(root)
    } else {
        guard root.right != nil else { return root }
        root.right = moveToRoot(root.right, key)
        return rotateLeft(root)
    }
}

// Insert: splay the nearest key to the root, then put the new key above it
func insert(_ key: Int, into root: Node?) -> Node {
    let node = Node(key)
    guard let top = splay(root, key) else { return node }
    if top.key == key { return top }
    if key < top.key {
        node.left = top.left
        node.right = top
        top.left = nil
    } else {
        node.right = top.right
        node.left = top
        top.right = nil
    }
    return node
}

// The number of levels, with an explicit stack: this tree can be a long chain
func height(_ root: Node?) -> Int {
    var tallest = 0
    var stack: [(Node, Int)] = root.map { [($0, 1)] } ?? []
    while let (node, depth) = stack.popLast() {
        tallest = max(tallest, depth)
        if let left = node.left { stack.append((left, depth + 1)) }
        if let right = node.right { stack.append((right, depth + 1)) }
    }
    return tallest
}

var root: Node? = nil
var naive: Node? = nil
for key in 1...1_000 {
    root = insert(key, into: root)
    naive = insert(key, into: naive)
}
print("after inserting 1...1000 in order: height \(height(root))")
root = splay(root, 1)
naive = moveToRoot(naive, 1)
print("after accessing 1: splay height \(height(root)), move-to-root height \(height(naive))")
root = splay(root, 2)
naive = moveToRoot(naive, 2)
print("after accessing 2: splay height \(height(root)), move-to-root height \(height(naive))")

rotations = 0
for key in 1...1_000 {
    root = splay(root, key)
}
print("splaying 1...1000 in order: \(rotations) rotations")
rotations = 0
for key in 1...1_000 {
    naive = moveToRoot(naive, key)
}
print("moving 1...1000 to the root in order: \(rotations) rotations")
