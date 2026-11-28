// Generated from src/dsa/content/lessons/swift-memory/swift-retain-cycles.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class TreeNode {
    let name: String
    var children: [TreeNode] = []
    var parent: TreeNode?

    init(_ name: String) { self.name = name }
    deinit { print("\(name) freed") }
}

do {
    let root = TreeNode("root")
    let child = TreeNode("child")
    root.children.append(child)
    child.parent = root
    print("tree built")
}
print("scope ended")
