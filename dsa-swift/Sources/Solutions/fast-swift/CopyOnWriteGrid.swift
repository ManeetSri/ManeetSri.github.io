// Problem: A copy-on-write grid (M68 · Copy-on-write for your own types)

public enum CopyOnWriteGrid {
    /// Counts how many times grid storage has been duplicated. A grid and every copy made from it share
    /// one counter.
    public final class CopyCounter {
        public private(set) var copies = 0

        public init() {}

        func recordCopy() {
            copies += 1
        }
    }

    /// A grid's cells, row by row in one flat array.
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

    /// A rows × columns grid of Ints with value semantics. Copies share storage until one of them changes;
    /// the first change duplicates the storage once, and later changes happen in place.
    public struct Grid {
        private var storage: Storage
        public let rows: Int
        public let columns: Int

        public init(rows: Int, columns: Int, repeating value: Int, counter: CopyCounter) {
            self.rows = rows
            self.columns = columns
            storage = Storage(cells: Array(repeating: value, count: rows * columns), counter: counter)
        }

        public var storageID: ObjectIdentifier {
            ObjectIdentifier(storage)
        }

        /// Gives this grid its own storage if another grid shares it: O(rows × columns), at most once per
        /// sharing. O(1) when the storage is already unique.
        private mutating func makeUnique() {
            if !isKnownUniquelyReferenced(&storage) {
                storage = storage.duplicate()
            }
        }

        public subscript(row: Int, column: Int) -> Int {
            get {
                storage.cells[row * columns + column]
            }
            set {
                makeUnique()
                storage.cells[row * columns + column] = newValue
            }
        }

        public func row(_ row: Int) -> [Int] {
            Array(storage.cells[(row * columns)..<((row + 1) * columns)])
        }

        /// Every cell is overwritten, so shared storage is replaced by new storage built directly, without
        /// duplicating the old cells first.
        public mutating func fill(_ value: Int) {
            if isKnownUniquelyReferenced(&storage) {
                for index in storage.cells.indices {
                    storage.cells[index] = value
                }
            } else {
                storage = Storage(cells: Array(repeating: value, count: rows * columns), counter: storage.counter)
            }
        }

        /// One uniqueness check for the whole row, not one per cell.
        public mutating func add(_ delta: Int, toRow row: Int) {
            makeUnique()
            for index in (row * columns)..<((row + 1) * columns) {
                storage.cells[index] += delta
            }
        }

        public mutating func swapRows(_ first: Int, _ second: Int) {
            guard first != second else { return }
            makeUnique()
            for column in 0..<columns {
                storage.cells.swapAt(first * columns + column, second * columns + column)
            }
        }

        public func isSharingStorage(with other: Grid) -> Bool {
            storageID == other.storageID
        }
    }
}
