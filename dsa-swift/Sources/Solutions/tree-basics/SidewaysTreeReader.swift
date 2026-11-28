// Reference solution: Read a sideways tree drawing. The drawing is reverse inorder, so the lines read
// bottom up give the nodes in inorder, each with its depth. A stack holds the path from the root to the
// last node placed; a new node pops every deeper node (the shallowest popped is its left child) and
// becomes the right child of whatever is left on top. O(total characters) time, O(h) extra space.

import DSAKit

public enum SidewaysTreeReader {
    public static func tree(fromLines lines: [String]) -> TreeNode? {
        var stack: [(node: TreeNode, depth: Int)] = []
        for line in lines.reversed() {                       // bottom up: inorder
            let spaces = line.prefix { $0 == " " }.count
            let node = TreeNode(Int(line.dropFirst(spaces))!)
            let depth = spaces / 4
            var lastPopped: TreeNode? = nil
            while let top = stack.last, top.depth > depth {
                lastPopped = stack.removeLast().node         // deeper nodes finish here
            }
            node.left = lastPopped                           // the shallowest of them
            stack.last?.node.right = node                    // the next node on its parent's right path
            stack.append((node, depth))
        }
        return stack.first?.node                             // depth 0: the root
    }
}
