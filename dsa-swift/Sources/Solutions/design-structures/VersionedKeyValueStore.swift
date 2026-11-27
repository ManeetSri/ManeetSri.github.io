// Reference solution: Versioned key-value store. Each key keeps its versions in an array of
// (time, value) pairs. Times only increase, so appending keeps every array sorted, and "the value
// at time t" is the last version at or before t: one binary search. `set` is amortised O(1) and
// `value(for:at:)` is O(log v) for a key with v versions.

import DSAKit

public enum VersionedKeyValueStore {
    public struct Store<Key: Hashable, Value> {
        private var versions: [Key: [(time: Int, value: Value)]] = [:]

        public init() {}

        public mutating func set(_ value: Value, for key: Key, at time: Int) {
            versions[key, default: []].append((time, value))   // in place: no copy of the array
        }

        public func value(for key: Key, at time: Int) -> Value? {
            guard let history = versions[key] else { return nil }
            let later = history.partitionPoint { $0.time > time }   // the first version after `time`
            return later == 0 ? nil : history[later - 1].value
        }
    }
}
