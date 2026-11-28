// Generated from src/dsa/content/lessons/tree-traversals/trav-dfs-recursive.mdx. Edit the lesson, then run
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

func preorder(_ node: TreeNode?, _ visit: (Int) -> Void) {
    guard let node else { return }
    visit(node.value)
    preorder(node.left, visit)
    preorder(node.right, visit)
}

func inorder(_ node: TreeNode?, _ visit: (Int) -> Void) {
    guard let node else { return }
    inorder(node.left, visit)
    visit(node.value)
    inorder(node.right, visit)
}

func postorder(_ node: TreeNode?, _ visit: (Int) -> Void) {
    guard let node else { return }
    postorder(node.left, visit)
    postorder(node.right, visit)
    visit(node.value)
}

let root = TreeNode(1,
                    left: TreeNode(2, left: TreeNode(4), right: TreeNode(5, left: TreeNode(7))),
                    right: TreeNode(3, right: TreeNode(6)))

var pre: [Int] = []
var ino: [Int] = []
var post: [Int] = []
preorder(root) { pre.append($0) }
inorder(root) { ino.append($0) }
postorder(root) { post.append($0) }
print("preorder: ", pre)
print("inorder:  ", ino)
print("postorder:", post)

var total = 0
inorder(root) { total += $0 }
print("sum:", total)
