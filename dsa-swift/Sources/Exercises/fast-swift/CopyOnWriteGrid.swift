// Problem: A copy-on-write grid (M68 · Copy-on-write for your own types)

public enum CopyOnWriteGrid {
    /// Counts how many times grid storage has been duplicated. A grid and every copy made from it share
    /// one counter. (Finished: don't change it.)
    public final class CopyCounter {
        public private(set) var copies = 0

        public init() {}

        func recordCopy() {
            copies += 1
        }
    }

    /// A grid's cells, row by row in one flat array. (Finished: don't change it.)
    final class Storage {
        var cells: [Int]
        let counter: CopyCounter

        init(cells: [Int], counter: CopyCounter) {
            self.cells = cells
            self.counter = counter
        }

        /// A new Storage with the same cells. Records one copy on the counter.
        func duplicate() -> Storage {
            counter.recordCopy()
            return Storage(cells: cells, counter: counter)
        }
    }

    /// A rows × columns grid of Ints with value semantics, built on shared Storage. Copies share storage
    /// until one of them changes. Duplicate storage only with `duplicate()`, and only when it's shared.
    public struct Grid {
        private var storage: Storage
        public let rows: Int
        public let columns: Int

        /// A grid with every cell set to `value`, counting its copies on `counter`.
        public init(rows: Int, columns: Int, repeating value: Int, counter: CopyCounter) {
            self.rows = rows
            self.columns = columns
            storage = Storage(cells: Array(repeating: value, count: rows * columns), counter: counter)
        }

        /// An identity for the storage this grid uses right now. It doesn't keep the storage alive.
        public var storageID: ObjectIdentifier {
            ObjectIdentifier(storage)
        }

        /// Reads or writes one cell. Writing must never change another copy of this grid.
        public subscript(row: Int, column: Int) -> Int {
            get {
                // Write your solution here, then run:
                // swift test --filter CopyOnWriteGridTests
                return 0
            }
            set {
            }
        }

        /// The cells of one row, from left to right.
        public func row(_ row: Int) -> [Int] {
            return []
        }

        /// Sets every cell to `value`. Never duplicates storage: when it's shared, build new storage
        /// directly instead.
        public mutating func fill(_ value: Int) {
        }

        /// Adds `delta` to every cell in one row.
        public mutating func add(_ delta: Int, toRow row: Int) {
        }

        /// Exchanges two rows. Swapping a row with itself changes nothing and never duplicates storage.
        public mutating func swapRows(_ first: Int, _ second: Int) {
        }

        /// True when this grid and `other` use the same storage object.
        public func isSharingStorage(with other: Grid) -> Bool {
            return false
        }
    }
}
