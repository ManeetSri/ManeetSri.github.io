// Generated from src/dsa/content/lessons/balanced-trees/bal-red-black.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

enum Colour { case red, black }

final class RBNode {
    let value: Int
    var colour = Colour.red              // every new node starts red
    var left: RBNode?
    var right: RBNode?
    weak var parent: RBNode?             // weak: a child mustn't keep its parent alive (no cycle)

    init(_ value: Int) { self.value = value }
}

func isRed(_ node: RBNode?) -> Bool {
    node?.colour == .red                 // nil leaves count as black
}

struct RedBlackTree {
    var root: RBNode?

    // Lifts x's right child y above x, fixing all three parent links
    mutating func rotateLeft(_ x: RBNode) {
        let y = x.right!
        x.right = y.left
        y.left?.parent = x
        y.parent = x.parent
        if let parent = x.parent {
            if parent.left === x { parent.left = y } else { parent.right = y }
        } else {
            root = y
        }
        y.left = x
        x.parent = y
    }

    mutating func rotateRight(_ y: RBNode) {
        let x = y.left!
        y.left = x.right
        x.right?.parent = y
        x.parent = y.parent
        if let parent = y.parent {
            if parent.left === y { parent.left = x } else { parent.right = x }
        } else {
            root = x
        }
        x.right = y
        y.parent = x
    }

    mutating func insert(_ value: Int) {
        // 1. An ordinary BST insert of a red node
        let node = RBNode(value)
        var parent: RBNode? = nil
        var current = root
        while let here = current {
            parent = here
            if value == here.value { return }            // already there
            current = value < here.value ? here.left : here.right
        }
        node.parent = parent
        if let parent {
            if value < parent.value { parent.left = node } else { parent.right = node }
        } else {
            root = node
        }
        // 2. Fix any red node with a red parent, working up the tree
        fixUp(node)
    }

    mutating func fixUp(_ start: RBNode) {
        var node = start
        while let parent = node.parent, parent.colour == .red {
            let grandparent = parent.parent!             // a red parent is never the root
            if parent === grandparent.left {
                let uncle = grandparent.right
                if isRed(uncle) {
                    // Case 1: red uncle. Recolour and move the problem up two levels.
                    parent.colour = .black
                    uncle!.colour = .black
                    grandparent.colour = .red
                    node = grandparent
                } else {
                    if node === parent.right {
                        // Case 2: black uncle, node is an inner grandchild. Rotate it outward.
                        node = parent
                        rotateLeft(node)
                    }
                    // Case 3: black uncle, node is an outer grandchild. Rotate and recolour.
                    node.parent!.colour = .black
                    grandparent.colour = .red
                    rotateRight(grandparent)
                }
            } else {
                // The mirror image, with left and right swapped
                let uncle = grandparent.left
                if isRed(uncle) {
                    parent.colour = .black
                    uncle!.colour = .black
                    grandparent.colour = .red
                    node = grandparent
                } else {
                    if node === parent.left {
                        node = parent
                        rotateRight(node)
                    }
                    node.parent!.colour = .black
                    grandparent.colour = .red
                    rotateLeft(grandparent)
                }
            }
        }
        root?.colour = .black                            // property 2: the root is black
    }
}

// The black-height of node's subtree if properties 4 and 5 hold there, or nil if not
func blackHeight(_ node: RBNode?) -> Int? {
    guard let node else { return 0 }                     // count black nodes, not the nil leaves
    if isRed(node) && (isRed(node.left) || isRed(node.right)) { return nil }   // red-red
    guard let left = blackHeight(node.left), let right = blackHeight(node.right),
          left == right else { return nil }              // unequal black counts
    return left + (node.colour == .black ? 1 : 0)
}

func height(_ node: RBNode?) -> Int {
    guard let node else { return 0 }
    return 1 + max(height(node.left), height(node.right))
}

// Each level, with R or B after each value
func levels(_ root: RBNode?) -> String {
    var lines: [String] = []
    var level = root.map { [$0] } ?? []
    while !level.isEmpty {
        lines.append(level.map { "\($0.value)\($0.colour == .red ? "R" : "B")" }.joined(separator: " "))
        level = level.flatMap { [$0.left, $0.right].compactMap { $0 } }
    }
    return lines.joined(separator: " | ")
}

var tree = RedBlackTree()
for value in 1...10 {
    tree.insert(value)
}
print(levels(tree.root))
print("black-height:", blackHeight(tree.root) ?? -1, "height:", height(tree.root))

var big = RedBlackTree()
for value in 1...1_000 {
    big.insert(value)
}
print("1,000 sorted inserts: height", height(big.root), "valid:", blackHeight(big.root) != nil)
