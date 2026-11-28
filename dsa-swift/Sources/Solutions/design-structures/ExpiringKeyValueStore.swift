// Reference solution: Expiring key-value store. A dictionary holds each live entry with the time it
// expires, and reads check that time (lazy expiry). A min-heap of (expiry, key) deadlines lets
// `count(now:)` throw out everything that has expired in one sweep from the top (eager cleanup).
// A deadline whose key has since been overwritten or removed is stale: it no longer matches the
// entry, so it's skipped. Every operation is amortised O(log n), where n is the number of deadlines.

import DSAKit

public enum ExpiringKeyValueStore {
    public struct Store<Key: Hashable, Value> {
        private var entries: [Key: (value: Value, expiresAt: Int)] = [:]
        private var deadlines = Heap<(expiresAt: Int, key: Key)>(areInIncreasingOrder: { $0.expiresAt < $1.expiresAt })

        public init() {}

        public mutating func set(_ value: Value, for key: Key, ttl: Int, now: Int) {
            precondition(ttl > 0, "A time to live must be at least 1")
            purge(now: now)
            entries[key] = (value, now + ttl)
            deadlines.insert((now + ttl, key))
            compactIfMostlyStale()
        }

        public mutating func value(for key: Key, now: Int) -> Value? {
            guard let entry = entries[key] else { return nil }
            guard entry.expiresAt > now else {
                entries[key] = nil                     // lazy expiry: found dead on read
                return nil
            }
            return entry.value
        }

        @discardableResult
        public mutating func removeValue(for key: Key, now: Int) -> Value? {
            guard let entry = entries.removeValue(forKey: key) else { return nil }
            return entry.expiresAt > now ? entry.value : nil
        }

        public mutating func count(now: Int) -> Int {
            purge(now: now)
            return entries.count
        }

        /// Pops every deadline that has passed. Only a deadline that still matches its entry removes it.
        private mutating func purge(now: Int) {
            while let next = deadlines.peek(), next.expiresAt <= now {
                deadlines.pop()
                if let entry = entries[next.key], entry.expiresAt == next.expiresAt {
                    entries[next.key] = nil
                }
            }
        }

        /// Overwrites leave stale deadlines behind. Once they outnumber the live entries, rebuild the
        /// heap from the entries: O(n) work that pays for the n operations that made the waste.
        private mutating func compactIfMostlyStale() {
            guard deadlines.count > 64 && deadlines.count > 2 * entries.count else { return }
            deadlines = Heap(entries.map { (expiresAt: $0.value.expiresAt, key: $0.key) },
                             areInIncreasingOrder: { $0.expiresAt < $1.expiresAt })
        }
    }
}
