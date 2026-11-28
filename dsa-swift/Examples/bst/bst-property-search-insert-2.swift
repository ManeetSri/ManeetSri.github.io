// Generated from src/dsa/content/lessons/bst/bst-property-search-insert.mdx. Edit the lesson, then run
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

func searchRecursive(_ target: Int, in node: TreeNode?) -> TreeNode? {
    guard let node else { return nil }
    if target == node.value { return node }
    return target < node.value ? searchRecursive(target, in: node.left) : searchRecursive(target, in: node.right)
}

func search(_ target: Int, in root: TreeNode?) -> TreeNode? {
    var current = root
    while let node = current {
        print("  at \(node.value)")
        if target == node.value { return node }
        current = target < node.value ? node.left : node.right
    }
    return nil
}

let root = TreeNode(50,
                    left: TreeNode(30, left: TreeNode(20), right: TreeNode(40, left: TreeNode(35))),
                    right: TreeNode(70, left: TreeNode(60), right: TreeNode(80)))
print("search 35:", search(35, in: root)?.value as Any)
print("search 65:", search(65, in: root)?.value as Any)
print("recursive 60:", searchRecursive(60, in: root)?.value as Any)
