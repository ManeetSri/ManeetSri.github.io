// A hash map built with separate chaining: an array of buckets, each holding the entries whose keys
// hash to it. The number of buckets is always a power of two, so a key's bucket is its hash value
// masked with `bucketCount - 1`. When the load factor (count / bucketCount) would pass 3/4, the map
// doubles its buckets and rehashes every entry, which keeps chains short and every operation O(1)
// on average. Built in M24, "Build your own HashMap and HashSet".

/// A generic hash map from `Key` to `Value`, using separate chaining.
///
/// It's a value type: copying a map gives an independent map, and the copy is cheap until one of
/// them changes, because the buckets are arrays with copy-on-write.
///
/// ```swift
/// var ages: HashMap = ["Ava": 31, "Ben": 27]
/// ages["Cleo"] = 35
/// ages["Ben"] = nil            // removes Ben
/// print(ages["Ava"] ?? 0)      // 31
/// ```
///
/// Iteration order depends on the keys' hash values, which Swift seeds randomly each run, so never
/// rely on it.
public struct HashMap<Key: Hashable, Value> {
    /// One key and its value, stored in a bucket.
    struct Entry {
        var key: Key
        var value: Value
    }

    /// The smallest number of buckets a map ever has.
    public static var minimumBucketCount: Int { 8 }

    private var buckets: [[Entry]]

    /// The number of key-value pairs. O(1).
    public private(set) var count: Int

    /// Creates an empty map. O(1).
    public init() {
        buckets = Array(repeating: [], count: Self.minimumBucketCount)
        count = 0
    }

    /// Creates an empty map with room for at least `minimumCapacity` entries before it needs to
    /// grow. O(capacity).
    public init(minimumCapacity: Int) {
        var bucketCount = Self.minimumBucketCount
        while minimumCapacity > bucketCount / 4 * 3 {
            bucketCount *= 2
        }
        buckets = Array(repeating: [], count: bucketCount)
        count = 0
    }

    /// Creates a map from a sequence of key-value pairs. A key that appears more than once keeps
    /// its last value. O(n) on average.
    public init<S: Sequence>(_ pairs: S) where S.Element == (Key, Value) {
        self.init()
        for (key, value) in pairs {
            self[key] = value
        }
    }

    /// Whether the map has no entries. O(1).
    public var isEmpty: Bool {
        count == 0
    }

    /// The number of buckets: always a power of two, at least `minimumBucketCount`. O(1).
    public var bucketCount: Int {
        buckets.count
    }

    /// `count / bucketCount`. The map keeps it at or below 0.75. O(1).
    public var loadFactor: Double {
        Double(count) / Double(buckets.count)
    }

    /// The bucket a key belongs in. The mask keeps the low bits of the hash value, which is never
    /// negative after masking, unlike `hashValue % bucketCount`.
    private func bucketIndex(for key: Key) -> Int {
        key.hashValue & (buckets.count - 1)
    }

    /// Reads, adds, replaces or removes the value for `key`. Reading a missing key gives `nil`;
    /// assigning `nil` removes the key. O(1) on average; amortised when the map grows.
    public subscript(key: Key) -> Value? {
        get {
            let index = bucketIndex(for: key)
            for entry in buckets[index] where entry.key == key {
                return entry.value
            }
            return nil
        }
        set {
            if let newValue {
                updateValue(newValue, forKey: key)
            } else {
                removeValue(forKey: key)
            }
        }
    }

    /// Reads the value for `key`, or `defaultValue` if it's missing. Assigning stores the value, so
    /// `counts[word, default: 0] += 1` counts in one line. O(1) on average.
    public subscript(key: Key, default defaultValue: @autoclosure () -> Value) -> Value {
        get {
            self[key] ?? defaultValue()
        }
        set {
            updateValue(newValue, forKey: key)
        }
    }

    /// Stores `value` for `key` and returns the value it replaced, or `nil` if the key is new.
    /// O(1) on average; amortised O(1) when the map grows.
    @discardableResult
    public mutating func updateValue(_ value: Value, forKey key: Key) -> Value? {
        let index = bucketIndex(for: key)
        if let position = buckets[index].firstIndex(where: { $0.key == key }) {
            let old = buckets[index][position].value
            buckets[index][position].value = value
            return old
        }
        buckets[index].append(Entry(key: key, value: value))
        count += 1
        if count > buckets.count / 4 * 3 {
            resize(to: buckets.count * 2)
        }
        return nil
    }

    /// Removes `key` and returns its value, or returns `nil` if it wasn't there. O(1) on average.
    @discardableResult
    public mutating func removeValue(forKey key: Key) -> Value? {
        let index = bucketIndex(for: key)
        guard let position = buckets[index].firstIndex(where: { $0.key == key }) else {
            return nil
        }
        count -= 1
        // Order within a bucket doesn't matter, so swap the last entry into the hole: O(1)
        return buckets[index].swapRemove(at: position).value
    }

    /// Whether the map has a value for `key`. O(1) on average.
    public func contains(key: Key) -> Bool {
        buckets[bucketIndex(for: key)].contains { $0.key == key }
    }

    /// Removes every entry and shrinks back to the minimum number of buckets. O(bucketCount).
    public mutating func removeAll() {
        buckets = Array(repeating: [], count: Self.minimumBucketCount)
        count = 0
    }

    /// Moves every entry into `newBucketCount` buckets. Each key's bucket can change, because the
    /// mask changes, so every entry is rehashed. O(n).
    private mutating func resize(to newBucketCount: Int) {
        var newBuckets = [[Entry]](repeating: [], count: newBucketCount)
        for bucket in buckets {
            for entry in bucket {
                newBuckets[entry.key.hashValue & (newBucketCount - 1)].append(entry)
            }
        }
        buckets = newBuckets
    }

    /// The length of the longest chain: 1 or 2 with a good hash, but `count` if every key
    /// collides. Useful for seeing collisions in tests. O(bucketCount).
    public var longestChain: Int {
        buckets.map(\.count).max() ?? 0
    }

    /// The keys, in no particular order. O(1) to create; iterating is O(n + bucketCount).
    public var keys: LazyMapSequence<HashMap<Key, Value>, Key> {
        lazy.map { $0.key }
    }

    /// The values, in the same order as `keys`. O(1) to create; iterating is O(n + bucketCount).
    public var values: LazyMapSequence<HashMap<Key, Value>, Value> {
        lazy.map { $0.value }
    }
}

extension Array {
    /// Removes the element at `index` by moving the last element into its place. O(1), but
    /// doesn't keep the order.
    fileprivate mutating func swapRemove(at index: Int) -> Element {
        swapAt(index, count - 1)
        return removeLast()
    }
}

extension HashMap: Sequence {
    /// Walks the buckets in order, and each bucket's entries in order.
    public struct Iterator: IteratorProtocol {
        private let buckets: [[Entry]]
        private var bucket = 0
        private var position = 0

        fileprivate init(buckets: [[Entry]]) {
            self.buckets = buckets
        }

        /// The next key-value pair, or `nil` at the end. O(1) amortised over a whole pass.
        public mutating func next() -> (key: Key, value: Value)? {
            while bucket < buckets.count {
                if position < buckets[bucket].count {
                    let entry = buckets[bucket][position]
                    position += 1
                    return (entry.key, entry.value)
                }
                bucket += 1
                position = 0
            }
            return nil
        }
    }

    /// An iterator over the key-value pairs, in no particular order. O(1).
    public func makeIterator() -> Iterator {
        Iterator(buckets: buckets)
    }

    /// The number of entries, so `Array(map)` allocates once. O(1).
    public var underestimatedCount: Int {
        count
    }
}

extension HashMap: ExpressibleByDictionaryLiteral {
    /// Creates a map from a literal such as `["a": 1, "b": 2]`. A repeated key keeps its last
    /// value. O(n) on average.
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.init(minimumCapacity: elements.count)
        for (key, value) in elements {
            self[key] = value
        }
    }
}

extension HashMap: CustomStringConvertible {
    /// Like a dictionary: `["a": 1, "b": 2]`, or `[:]` when empty. The order is arbitrary. O(n).
    public var description: String {
        if isEmpty {
            return "[:]"
        }
        let pairs = map { "\(String(reflecting: $0.key)): \(String(reflecting: $0.value))" }
        return "[" + pairs.joined(separator: ", ") + "]"
    }
}

extension HashMap: Equatable where Value: Equatable {
    /// Two maps are equal when they have the same keys with equal values, whatever their bucket
    /// layout. O(n) on average.
    public static func == (lhs: HashMap, rhs: HashMap) -> Bool {
        guard lhs.count == rhs.count else {
            return false
        }
        return lhs.allSatisfy { rhs[$0.key] == $0.value }
    }
}
