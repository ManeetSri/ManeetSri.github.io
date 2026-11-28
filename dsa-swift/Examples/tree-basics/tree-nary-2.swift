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

func preorder(_ node: NaryNode, into result: inout [Int]) {
    result.append(node.value)                 // the node first
    for child in node.children {
        preorder(child, into: &result)
    }
}

func postorder(_ node: NaryNode, into result: inout [Int]) {
    for child in node.children {
        postorder(child, into: &result)
    }
    result.append(node.value)                 // the node last
}

// Preorder without recursion: push the children in reverse so the first child comes off first
func preorderWithStack(_ root: NaryNode) -> [Int] {
    var result: [Int] = []
    var stack = [root]
    while let node = stack.popLast() {
        result.append(node.value)
        stack.append(contentsOf: node.children.reversed())
    }
    return result
}

func levels(_ root: NaryNode) -> [[Int]] {
    var result: [[Int]] = []
    var level = [root]
    while !level.isEmpty {
        result.append(level.map(\.value))
        level = level.flatMap(\.children)      // every child of every node on this level
    }
    return result
}

let root = NaryNode(1, children: [
    NaryNode(2, children: [NaryNode(5), NaryNode(6, children: [NaryNode(10)])]),
    NaryNode(3),
    NaryNode(4, children: [NaryNode(7), NaryNode(8), NaryNode(9)]),
])
var pre: [Int] = []
var post: [Int] = []
preorder(root, into: &pre)
postorder(root, into: &post)
print("preorder: ", pre)
print("with stack:", preorderWithStack(root))
print("postorder:", post)
print("levels:   ", levels(root))
