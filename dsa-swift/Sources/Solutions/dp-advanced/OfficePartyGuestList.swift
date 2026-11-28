// Reference solution: The office party guest list. House robber on a tree. Each node returns two
// answers for its subtree: the best total with this person invited (then their direct reports are
// not), and the best with them left out (then each report is free to come or not). A post-order pass
// fills both from the children's pairs, so every node is visited once. Leaving someone out is always
// allowed, which also takes care of negative fun and the empty list.
// O(n) time, O(h) stack for a tree of height h (the tests keep h well under 1,000).

import DSAKit

public enum OfficePartyGuestList {
    public static func maximumFun(_ root: TreeNode?) -> Int {
        func best(_ node: TreeNode?) -> (invited: Int, leftOut: Int) {
            guard let node else { return (0, 0) }
            let left = best(node.left)
            let right = best(node.right)
            let invited = node.value + left.leftOut + right.leftOut
            let leftOut = max(left.invited, left.leftOut) + max(right.invited, right.leftOut)
            return (invited, leftOut)
        }
        let answer = best(root)
        return max(answer.invited, answer.leftOut)
    }
}
