// Generated from src/dsa/content/lessons/tree-traversals/trav-morris.mdx. Edit the lesson, then run
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

// The shape in preorder, with "-" for a missing child
func shape(_ node: TreeNode?) -> String {
    guard let node else { return "-" }
    return "\(node.value)(\(shape(node.left)) \(shape(node.right)))"
}

func morris(_ root: TreeNode?, preorder: Bool) -> [Int] {
    var result: [Int] = []
    var current = root
    while let node = current {
        guard let left = node.left else {
            result.append(node.value)
            current = node.right
            continue
        }
        var predecessor = left
        while let next = predecessor.right, next !== node {
            predecessor = next
        }
        if predecessor.right == nil {
            if preorder { result.append(node.value) }     // preorder: visit on the way down
            predecessor.right = node
            current = left
        } else {
            if !preorder { result.append(node.value) }    // inorder: visit on the way back
            predecessor.right = nil
            current = node.right
        }
    }
    return result
}

let root = TreeNode(1,
                    left: TreeNode(2, left: TreeNode(4), right: TreeNode(5, left: TreeNode(7))),
                    right: TreeNode(3, right: TreeNode(6)))
let before = shape(root)
print("inorder: ", morris(root, preorder: false))
print("preorder:", morris(root, preorder: true))
print("shape:   ", before)
print("restored:", shape(root) == before)
