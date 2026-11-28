// Problem: Build a B-tree, split by split (M38 · B-trees and B+ trees)

public enum BTreeLevelsBuilder {
    /// Inserts `keys` in order into an empty B-tree whose nodes hold at most `maxKeys` keys and returns
    /// its levels, top first: each level lists its nodes left to right, each node its sorted keys.
    /// Duplicates are ignored. An overfull node sends the key at index count / 2 up to its parent.
    public static func levels(afterInserting keys: [Int], maxKeys: Int) -> [[[Int]]] {
        // Write your solution here, then run:
        // swift test --filter BTreeLevelsBuilderTests
        return []
    }
}
