// Generated from src/dsa/content/lessons/binary-trees/bt-invert-subtree.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Shape: Hashable {
    let value: Int
    let left: Int                                       // the left subtree's ID; 0 is the empty tree
    let right: Int
}

func containsByIDs(_ pattern: TreeNode?, in tree: TreeNode?) -> Bool {
    guard pattern != nil else { return true }
    var ids: [Shape: Int] = [:]                         // every distinct subtree seen so far
    var idsInTree: Set<Int> = []
    var recording = true
    func id(of node: TreeNode?) -> Int {
        guard let node else { return 0 }
        let shape = Shape(value: node.value, left: id(of: node.left), right: id(of: node.right))
        let number: Int
        if let known = ids[shape] {
            number = known
        } else {
            number = ids.count + 1
            ids[shape] = number
        }
        if recording {
            idsInTree.insert(number)
        }
        return number
    }
    _ = id(of: tree)
    recording = false
    return idsInTree.contains(id(of: pattern))
}

let tree = TreeNode.make([7, 2, 9, 1, 5])
print(containsByIDs(TreeNode.make([2, 1, 5]), in: tree))
print(containsByIDs(TreeNode.make([2, 1]), in: tree))

let zeros = TreeNode.make(Array(repeating: 0, count: 1_023))
print(containsByIDs(TreeNode.make([0, 0, 0, 0, 0, 0, 1]), in: zeros))
print(containsByIDs(TreeNode.make([0, 0, 0, 0, 0, 0, 0]), in: zeros))

// MARK: - The TreeNode from DSAKit, cut down so this file runs on its own

final class TreeNode {
    var value: Int
    var left: TreeNode?
    var right: TreeNode?

    init(_ value: Int, left: TreeNode? = nil, right: TreeNode? = nil) {
        self.value = value
        self.left = left
        self.right = right
    }

    /// Builds a tree from its level order, with nil for a missing child, like TreeNode.make in DSAKit
    static func make(_ levelOrder: [Int?]) -> TreeNode? {
        guard let first = levelOrder.first, let rootValue = first else { return nil }
        let root = TreeNode(rootValue)
        var parents = [root]
        var head = 0
        var index = 1
        while index < levelOrder.count && head < parents.count {
            let parent = parents[head]
            head += 1
            if let value = levelOrder[index] {
                parent.left = TreeNode(value)
                parents.append(parent.left!)
            }
            index += 1
            if index < levelOrder.count, let value = levelOrder[index] {
                parent.right = TreeNode(value)
                parents.append(parent.right!)
            }
            index += 1
        }
        return root
    }
}
