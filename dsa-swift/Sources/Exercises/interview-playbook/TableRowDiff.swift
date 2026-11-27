// Problem: Table row diff (M71 · iOS-flavoured DSA questions)

public enum TableRowDiff {
    /// The batch update for a table view: rows to delete, as indexes into the old list, and rows to
    /// insert, as indexes into the new list. Both are in increasing order.
    public struct Changes: Equatable, CustomStringConvertible {
        public var deletions: [Int]
        public var insertions: [Int]

        public init(deletions: [Int], insertions: [Int]) {
            self.deletions = deletions
            self.insertions = insertions
        }

        public var description: String { "deletions \(deletions), insertions \(insertions)" }
    }

    /// The fewest deletions plus insertions that turn the rows `old` into the rows `new`. Rows that aren't
    /// deleted keep their order. Ids are unique within each list. Any answer with the fewest changes is
    /// accepted.
    public static func changes(from old: [String], to new: [String]) -> Changes {
        // Write your solution here, then run:
        // swift test --filter TableRowDiffTests
        return Changes(deletions: [], insertions: [])
    }
}
