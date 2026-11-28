// Generated from src/dsa/content/lessons/tree-basics/tree-nary.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class NaryNode {
    let value: Int
    var children: [NaryNode]

    init(_ value: Int, children: [NaryNode] = []) {
        self.value = value
        self.children = children
    }
}

func size(_ node: NaryNode) -> Int {
    1 + node.children.reduce(0) { $0 + size($1) }
}

func height(_ node: NaryNode) -> Int {
    1 + (node.children.map(height).max() ?? 0)      // a leaf has no children, so max() is nil
}

func leaves(_ node: NaryNode) -> [Int] {
    node.children.isEmpty ? [node.value] : node.children.flatMap(leaves)
}

let root = NaryNode(1, children: [
    NaryNode(2, children: [NaryNode(5), NaryNode(6, children: [NaryNode(10)])]),
    NaryNode(3),
    NaryNode(4, children: [NaryNode(7), NaryNode(8), NaryNode(9)]),
])
print("size \(size(root)), height \(height(root))")
print("leaves, left to right:", leaves(root))
