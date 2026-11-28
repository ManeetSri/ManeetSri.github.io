// Problem: Vertical columns (M35 · Vertical order and boundary traversal)

import DSAKit

public enum VerticalColumns {
    /// The values column by column, from the leftmost column to the rightmost. The root is in column 0
    /// on row 0; a left child is one column to the left and one row down, a right child one column to
    /// the right and one row down. Within a column, nodes go top to bottom by row, and nodes on the
    /// same row and column go in increasing order of value. The empty tree gives `[]`.
    public static func columns(_ root: TreeNode?) -> [[Int]] {
        // Write your solution here, then run:
        // swift test --filter VerticalColumnsTests
        return []
    }
}
