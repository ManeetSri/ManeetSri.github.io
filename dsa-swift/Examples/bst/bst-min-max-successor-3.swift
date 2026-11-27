// Generated from src/dsa/content/lessons/bst/bst-min-max-successor.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class TreeNode {
    var value: Int
    var left: TreeNode?
    var right: TreeNode?

    init(_ value: Int, left: TreeNode? = nil, right: TreeNode? = nil) {
        self.value = value
        self.left = left
        self.right = right
    }
}

// The smallest value bigger than x, or nil
func successor(of x: Int, in root: TreeNode?) -> Int? {
    var best: Int? = nil
    var current = root
    while let node = current {
        if node.value > x {
            best = node.value                  // a candidate; look for a smaller one on the left
            current = node.left
        } else {
            current = node.right               // too small (or equal): the answer is to the right
        }
    }
    return best
}

// The biggest value smaller than x, or nil
func predecessor(of x: Int, in root: TreeNode?) -> Int? {
    var best: Int? = nil
    var current = root
    while let node = current {
        if node.value < x {
            best = node.value
            current = node.right
        } else {
            current = node.left
        }
    }
    return best
}

let root = TreeNode(50,
                    left: TreeNode(30, left: TreeNode(20), right: TreeNode(40, left: TreeNode(35))),
                    right: TreeNode(70, left: TreeNode(60, right: TreeNode(65)), right: TreeNode(80)))
for x in [40, 65, 80, 45, 10] {
    print(x, "successor:", successor(of: x, in: root) as Any, "predecessor:", predecessor(of: x, in: root) as Any)
}
