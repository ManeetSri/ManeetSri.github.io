// Reference solution: A hash map from scratch. An array of buckets, each an array of key-value
// pairs (separate chaining). The bucket count is a power of two, so masking the hash value with
// bucketCount - 1 picks a bucket and is never negative. Growing past a load factor of 3/4 doubles
// the buckets and rehashes everything, which keeps chains short: O(1) average per operation,
// amortised for insertions that trigger a resize. O(n) space.

public enum HashMapFromScratch {
    public struct Map<Key: Hashable, Value> {
        private var buckets: [[(key: Key, value: Value)]] = Array(repeating: [], count: 8)
        private var storedCount = 0

        public init() {}

        public var count: Int {
            storedCount
        }

        public var isEmpty: Bool {
            storedCount == 0
        }

        public var bucketCount: Int {
            buckets.count
        }

        private func index(for key: Key) -> Int {
            key.hashValue & (buckets.count - 1)
        }

        public subscript(key: Key) -> Value? {
            get {
                buckets[index(for: key)].first { $0.key == key }?.value
            }
            set {
                guard let newValue else {
                    removeValue(forKey: key)
                    return
                }
                let bucket = index(for: key)
                if let position = buckets[bucket].firstIndex(where: { $0.key == key }) {
                    buckets[bucket][position].value = newValue
                    return
                }
                buckets[bucket].append((key, newValue))
                storedCount += 1
                if storedCount > buckets.count * 3 / 4 {
                    resize()
                }
            }
        }

        @discardableResult
        public mutating func removeValue(forKey key: Key) -> Value? {
            let bucket = index(for: key)
            guard let position = buckets[bucket].firstIndex(where: { $0.key == key }) else {
                return nil
            }
            storedCount -= 1
            return buckets[bucket].remove(at: position).value
        }

        public var keys: [Key] {
            buckets.flatMap { bucket in bucket.map { $0.key } }
        }

        // Every key's bucket depends on bucketCount, so every entry is placed again
        private mutating func resize() {
            var newBuckets = [[(key: Key, value: Value)]](repeating: [], count: buckets.count * 2)
            for bucket in buckets {
                for entry in bucket {
                    newBuckets[entry.key.hashValue & (newBuckets.count - 1)].append(entry)
                }
            }
            buckets = newBuckets
        }
    }
}
