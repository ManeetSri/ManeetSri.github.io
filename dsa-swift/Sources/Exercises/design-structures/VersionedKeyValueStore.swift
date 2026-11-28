// Problem: Versioned key-value store (M72 · Hit counter and time-based key-value store)

public enum VersionedKeyValueStore {
    /// A key-value store that remembers every value a key has had, so you can ask what it was at
    /// any moment. The times passed to `set` strictly increase from one call to the next.
    public struct Store<Key: Hashable, Value> {
        // Write your solution here, then run:
        // swift test --filter VersionedKeyValueStoreTests
        // Add whatever private storage you need.

        /// Creates an empty store.
        public init() {
        }

        /// Gives `key` the value `value` from `time` on.
        public mutating func set(_ value: Value, for key: Key, at time: Int) {
        }

        /// The value `key` had at `time`: the one set at the latest time at or before `time`, or nil
        /// if the key had no value yet.
        public func value(for key: Key, at time: Int) -> Value? {
            return nil
        }
    }
}
