// Reference solution: Serialise and deserialise a tree. Preorder with a marker for every missing child:
// "1,2,#,#,3,#,#" is 1 with leaves 2 and 3. The markers say exactly where each subtree ends, so reading
// the tokens back in the same preorder rebuilds the same shape. Both directions are O(n): the string
// is built by appending, and parsed with one split.

import DSAKit

public enum TreeStringCodec {
    public static func serialise(_ root: TreeNode?) -> String {
        var text = ""
        func write(_ node: TreeNode?) {
            guard let node else {
                text += "#,"
                return
            }
            text += "\(node.value),"
            write(node.left)
            write(node.right)
        }
        write(root)
        text.removeLast()                            // the comma after the last token
        return text
    }

    public static func deserialise(_ text: String) -> TreeNode? {
        let tokens = text.split(separator: ",")
        var next = 0                                 // the next token to read
        func read() -> TreeNode? {
            guard next < tokens.count else { return nil }
            let token = tokens[next]
            next += 1
            guard let value = Int(token) else { return nil }    // "#": no node here
            let node = TreeNode(value)
            node.left = read()
            node.right = read()
            return node
        }
        return read()
    }
}
