// Problem: Snapshot array (M72 · Snapshot array)

public enum SnapshotArrayDesign {
    /// An array of Ints that can take numbered snapshots of itself and read any index as it was
    /// in any snapshot.
    public struct SnapshotArray {
        // Write your solution here, then run:
        // swift test --filter SnapshotArrayDesignTests
        // Add whatever private storage you need. Copying the whole array per snapshot is too slow.

        /// Creates an array of `count` zeros. No snapshot has been taken yet.
        public init(count: Int) {
        }

        /// The number of elements.
        public var count: Int {
            return 0
        }

        /// The current value at `index`, including changes since the last snapshot.
        public subscript(index: Int) -> Int {
            return 0
        }

        /// Sets the current value at `index`.
        public mutating func set(_ value: Int, at index: Int) {
        }

        /// Takes a snapshot and returns its id: 0 for the first, then 1, 2 and so on.
        public mutating func snapshot() -> Int {
            return 0
        }

        /// The value at `index` when snapshot `id` was taken. `id` is always one already returned.
        public func value(at index: Int, snapshot id: Int) -> Int {
            return 0
        }
    }
}
