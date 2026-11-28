// Generated from src/dsa/content/lessons/tree-traversals/trav-dfs-recursive.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class ExprNode {
    let label: String
    var left: ExprNode?
    var right: ExprNode?

    init(_ label: String, _ left: ExprNode? = nil, _ right: ExprNode? = nil) {
        self.label = label
        self.left = left
        self.right = right
    }
}

func preorder(_ node: ExprNode?) -> [String] {
    guard let node else { return [] }
    return [node.label] + preorder(node.left) + preorder(node.right)
}

func inorder(_ node: ExprNode?) -> [String] {
    guard let node else { return [] }
    return inorder(node.left) + [node.label] + inorder(node.right)
}

func postorder(_ node: ExprNode?) -> [String] {
    guard let node else { return [] }
    return postorder(node.left) + postorder(node.right) + [node.label]
}

// Postorder evaluation: both operands are known before their operator
func evaluate(_ node: ExprNode) -> Int {
    guard let left = node.left, let right = node.right else {
        return Int(node.label)!                       // a leaf holds a number
    }
    let a = evaluate(left)
    let b = evaluate(right)
    return node.label == "+" ? a + b : a * b
}

let expression = ExprNode("*", ExprNode("3"), ExprNode("+", ExprNode("4"), ExprNode("5")))
print("prefix: ", preorder(expression).joined(separator: " "))
print("infix:  ", inorder(expression).joined(separator: " "))
print("postfix:", postorder(expression).joined(separator: " "))
print("value:  ", evaluate(expression))
