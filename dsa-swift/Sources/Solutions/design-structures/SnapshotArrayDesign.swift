// Reference solution: Snapshot array. Instead of copying the whole array at every snapshot, each
// index keeps a short history of (snapshot, value) pairs: the value it had when that snapshot was
// taken, recorded only when it changed. A lookup is a binary search for the last change at or
// before the snapshot. `set` and `snapshot()` are O(1) (amortised), `value(at:snapshot:)` is
// O(log c) for an index changed c times, and memory is O(count + number of sets).

import DSAKit

public enum SnapshotArrayDesign {
    public struct SnapshotArray {
        /// For each index, the snapshots in which it changed, in order, with its value in each.
        private var history: [[(snapshot: Int, value: Int)]]
        private var snapshotsTaken = 0

        public init(count: Int) {
            precondition(count >= 0, "The count can't be negative")
            history = Array(repeating: [], count: count)
        }

        public var count: Int {
            history.count
        }

        public subscript(index: Int) -> Int {
            history[index].last?.value ?? 0
        }

        public mutating func set(_ value: Int, at index: Int) {
            // Changes made before the next snapshot belong to snapshot number `snapshotsTaken`
            if let last = history[index].last, last.snapshot == snapshotsTaken {
                history[index][history[index].count - 1].value = value   // changed twice: overwrite
            } else {
                history[index].append((snapshotsTaken, value))
            }
        }

        public mutating func snapshot() -> Int {
            snapshotsTaken += 1
            return snapshotsTaken - 1
        }

        public func value(at index: Int, snapshot id: Int) -> Int {
            precondition(id >= 0 && id < snapshotsTaken, "No snapshot \(id) has been taken")
            let changes = history[index]
            let later = changes.partitionPoint { $0.snapshot > id }     // first change after `id`
            return later == 0 ? 0 : changes[later - 1].value
        }
    }
}
