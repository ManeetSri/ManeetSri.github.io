// Generated from src/dsa/content/lessons/swift-memory/swift-weak-unowned.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class TreeNode {
    let name: String
    var children: [TreeNode] = []
    weak var parent: TreeNode?

    init(_ name: String) { self.name = name }
    deinit { print("\(name) freed") }

    func add(_ child: TreeNode) {
        children.append(child)
        child.parent = self
    }
}

do {
    let root = TreeNode("root")
    let child = TreeNode("child")
    root.add(child)
    print(child.parent?.name ?? "no parent")
}
print("scope ended")

let leaf = TreeNode("leaf")
do {
    let root = TreeNode("root")
    root.add(leaf)
    print(leaf.parent?.name ?? "no parent")
}
print(leaf.parent?.name ?? "no parent")
