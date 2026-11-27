// Generated from src/dsa/content/lessons/interview-playbook/int-swift-gotchas.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class TreeNode {
    var value: Int
    var left: TreeNode?
    init(_ value: Int) {
        self.value = value
    }
}
let root = TreeNode(1)
print(root.left?.value == root.left?.left?.value)   // nil == nil is true
let names: [String]? = nil
print(names?.isEmpty == true, names?.isEmpty ?? true)
if let leftValue = root.left?.value {
    print("left child holds", leftValue)
} else {
    print("no left child")
}
