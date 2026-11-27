// Problem: The last day to cross the field (M59 · Mixed-pattern drills)

import DSAKit

public enum LastDryCrossingDay {
    /// A rows × cols field starts dry. On day d (from 1), the cell `floods[d - 1]` = [row, col] floods for
    /// good. A hiker starts on any dry top-row cell and steps up, down, left or right between dry cells.
    /// Returns the largest d (0 means before any flooding) such that, after the first d floods, the hiker
    /// can still reach the bottom row.
    public static func lastDay(rows: Int, cols: Int, floods: [[Int]]) -> Int {
        // Write your solution here, then run:
        // swift test --filter LastDryCrossingDayTests
        // DSAKit is imported, so its Deque, Heap, UnionFind and friends are there if you want them.
        return 0
    }
}
