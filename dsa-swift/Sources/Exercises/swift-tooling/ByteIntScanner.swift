// Problem: A byte-level integer scanner (M12 · Fast input for competitive programming)

public enum ByteIntScanner {
    /// Reads integers one at a time from ASCII bytes, the way a fast input reader does.
    public struct Reader {
        private let bytes: [UInt8]
        private var position = 0

        public init(_ bytes: [UInt8]) {
            self.bytes = bytes
        }

        /// The next integer, skipping any whitespace before it, or nil when only whitespace is left.
        public mutating func nextInt() -> Int? {
            // Write your solution here, then run:
            // swift test --filter ByteIntScannerTests
            return nil
        }
    }

    /// Every integer in `bytes`, in order.
    public static func integers(in bytes: [UInt8]) -> [Int] {
        return []
    }
}
