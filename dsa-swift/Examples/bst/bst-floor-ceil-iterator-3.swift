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

// Visits values in increasing order, or decreasing order when `reversed` is true
struct BSTWalker: IteratorProtocol {
    private var stack: [TreeNode] = []
    private let reversed: Bool

    init(_ root: TreeNode?, reversed: Bool) {
        self.reversed = reversed
        pushSpine(from: root)
    }

    private mutating func pushSpine(from start: TreeNode?) {
        var current = start
        while let node = current {
            stack.append(node)
            current = reversed ? node.right : node.left
        }
    }

    mutating func next() -> Int? {
        guard let node = stack.popLast() else { return nil }
        pushSpine(from: reversed ? node.left : node.right)
        return node.value
    }
}

func pairSum(_ target: Int, in root: TreeNode?) -> (Int, Int)? {
    var up = BSTWalker(root, reversed: false)
    var down = BSTWalker(root, reversed: true)
    var low = up.next()
    var high = down.next()
    while let small = low, let big = high, small < big {
        let sum = small + big
        if sum == target {
            return (small, big)
        } else if sum < target {
            low = up.next()                        // need more: move the small end up
        } else {
            high = down.next()                     // need less: move the big end down
        }
    }
    return nil
}

let root = TreeNode(50,
                    left: TreeNode(30, left: TreeNode(20), right: TreeNode(40, left: TreeNode(35))),
                    right: TreeNode(70, left: TreeNode(60), right: TreeNode(80)))
print(pairSum(95, in: root) as Any)
print(pairSum(100, in: root) as Any)
print(pairSum(41, in: root) as Any)
