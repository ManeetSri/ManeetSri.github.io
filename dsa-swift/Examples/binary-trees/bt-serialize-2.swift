// Generated from src/dsa/content/lessons/binary-trees/bt-serialize.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func serialiseByLevels(_ root: TreeNode?) -> String {
    var tokens: [String] = []
    var queue: [TreeNode?] = [root]
    var head = 0
    while head < queue.count {
        let node = queue[head]
        head += 1
        if let node {
            tokens.append(String(node.value))
            queue.append(node.left)
            queue.append(node.right)
        } else {
            tokens.append("#")
        }
    }
    while tokens.last == "#" {
        tokens.removeLast()                             // trailing markers say nothing
    }
    return tokens.joined(separator: ",")
}

func deserialiseByLevels(_ text: String) -> TreeNode? {
    let tokens = text.split(separator: ",")
    guard let first = tokens.first, let rootValue = Int(first) else { return nil }
    let root = TreeNode(rootValue)
    var waiting = [root]                                // nodes whose children come next, in order
    var head = 0
    var index = 1
    while index < tokens.count {
        let parent = waiting[head]
        head += 1
        if let value = Int(tokens[index]) {
            parent.left = TreeNode(value)
            waiting.append(parent.left!)
        }
        index += 1
        if index < tokens.count, let value = Int(tokens[index]) {
            parent.right = TreeNode(value)
            waiting.append(parent.right!)
        }
        index += 1
    }
    return root
}

let text = serialiseByLevels(TreeNode.make([1, 2, 3, nil, nil, 4, 5]))
print(text)
print(serialiseByLevels(deserialiseByLevels(text)))
print(serialiseByLevels(deserialiseByLevels("8,#,9,#,10")))

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
