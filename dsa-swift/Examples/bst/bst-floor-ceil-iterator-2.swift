// Generated from src/dsa/content/lessons/bst/bst-floor-ceil-iterator.mdx. Edit the lesson, then run
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

struct InorderIterator: IteratorProtocol {
    private var stack: [TreeNode] = []

    init(_ root: TreeNode?) {
        pushLeftSpine(from: root)
    }

    private mutating func pushLeftSpine(from start: TreeNode?) {
        var current = start
        while let node = current {
            stack.append(node)
            current = node.left
        }
    }

    mutating func next() -> Int? {
        guard let node = stack.popLast() else { return nil }
        pushLeftSpine(from: node.right)
        return node.value
    }

    var waiting: [Int] { stack.map(\.value) }       // for printing only
}

struct SortedValues: Sequence {
    let root: TreeNode?
    func makeIterator() -> InorderIterator { InorderIterator(root) }
}

let root = TreeNode(50,
                    left: TreeNode(30, left: TreeNode(20), right: TreeNode(40, left: TreeNode(35))),
                    right: TreeNode(70, left: TreeNode(60), right: TreeNode(80)))

var iterator = InorderIterator(root)
print("start, stack \(iterator.waiting)")
while let value = iterator.next() {
    print("next() -> \(value), stack \(iterator.waiting)")
}

for value in SortedValues(root: root) where value > 45 {
    print(value, terminator: " ")
}
print()
print(SortedValues(root: root).prefix(3).map { $0 * 10 })
