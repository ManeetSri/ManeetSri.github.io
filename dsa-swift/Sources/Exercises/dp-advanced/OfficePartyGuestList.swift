// Problem: The office party guest list (M58 · DP on trees)

import DSAKit

public enum OfficePartyGuestList {
    /// The largest total fun of a guest list for the org chart rooted at `root`, where nobody is invited
    /// together with their direct manager (a node's parent). Values may be negative, and the empty
    /// guest list (total 0) is allowed, so the answer is never below 0. The empty chart gives 0.
    public static func maximumFun(_ root: TreeNode?) -> Int {
        // Write your solution here, then run:
        // swift test --filter OfficePartyGuestListTests
        return 0
    }
}
