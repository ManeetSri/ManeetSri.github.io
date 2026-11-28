// Problem: A hash map from scratch (M24 · Build your own HashMap and HashSet)

public enum HashMapFromScratch {
    /// A hash map with separate chaining. Don't use Dictionary or Set inside it.
    ///
    /// - Start with 8 buckets.
    /// - After an insertion of a new key, if `count > bucketCount * 3 / 4`, double the buckets and
    ///   move every entry to its new bucket.
    /// - Never shrink.
    public struct Map<Key: Hashable, Value> {
        // Add your storage here, for example: private var buckets: [[(key: Key, value: Value)]]

        public init() {
            // Write your solution here, then run:
            // swift test --filter HashMapFromScratchTests
        }

        /// The number of keys stored.
        public var count: Int {
            return 0
        }

        /// Whether the map is empty.
        public var isEmpty: Bool {
            return count == 0
        }

        /// The number of buckets: 8 at first, doubling as the map grows.
        public var bucketCount: Int {
            return 0
        }

        /// Reads the value for `key` (nil if it's missing), stores a new value, or removes the key
        /// when you assign nil.
        public subscript(key: Key) -> Value? {
            get {
                return nil
            }
            set {
            }
        }

        /// Removes `key` and returns its value, or returns nil if it wasn't there.
        @discardableResult
        public mutating func removeValue(forKey key: Key) -> Value? {
            return nil
        }

        /// Every key, in any order.
        public var keys: [Key] {
            return []
        }
    }
}
