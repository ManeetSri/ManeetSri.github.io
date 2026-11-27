// Generated from src/dsa/content/lessons/bst/bst-floor-ceil-iterator.mdx. Edit the lesson, then run
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

func floor(_ x: Int, in root: TreeNode?) -> Int? {
    var best: Int? = nil
    var current = root
    while let node = current {
        if node.value == x {
            return x
        } else if node.value < x {
            best = node.value                      // a candidate; a bigger one may be to the right
            current = node.right
        } else {
            current = node.left
        }
    }
    return best
}

func ceiling(_ x: Int, in root: TreeNode?) -> Int? {
    var best: Int? = nil
    var current = root
    while let node = current {
        if node.value == x {
            return x
        } else if node.value > x {
            best = node.value                      // a candidate; a smaller one may be to the left
            current = node.left
        } else {
            current = node.right
        }
    }
    return best
}

//            50
//         /      \
//       30        70
//      /  \      /  \
//    20    40  60    80
//         /
//       35
let root = TreeNode(50,
                    left: TreeNode(30, left: TreeNode(20), right: TreeNode(40, left: TreeNode(35))),
                    right: TreeNode(70, left: TreeNode(60), right: TreeNode(80)))
for x in [45, 35, 10, 90, 55] {
    print(x, "floor:", floor(x, in: root) as Any, "ceiling:", ceiling(x, in: root) as Any)
}
