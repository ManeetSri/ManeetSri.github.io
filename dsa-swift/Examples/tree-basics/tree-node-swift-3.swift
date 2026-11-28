// Generated from src/dsa/content/lessons/tree-basics/tree-node-swift.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class Node {
    let value: Int
    var children: [Node] = []
    weak var parent: Node?                    // doesn't keep the parent alive

    init(_ value: Int) {
        self.value = value
    }

    func add(_ child: Node) {
        children.append(child)
        child.parent = self
    }
}

let root = Node(1)
let two = Node(2)
let five = Node(5)
let seven = Node(7)
root.add(two)
two.add(five)
five.add(seven)

var path: [Int] = []
var current: Node? = seven
while let node = current {
    path.append(node.value)
    current = node.parent
}
print("from 7 up to the root:", path)
