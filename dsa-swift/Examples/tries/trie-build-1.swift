// Generated from src/dsa/content/lessons/tries/trie-build.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct StructNode {
    var children: [Character: StructNode] = [:]
    var isWord = false
}

var root = StructNode()
var node = root                          // a copy of root, not root itself
node.children["c"] = StructNode()
print("root has", root.children.count, "children; the copy has", node.children.count)
