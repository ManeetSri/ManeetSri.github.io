// Problem: A coalescing memo cache (M70 · Actors as thread-safe caches)

public enum CoalescingMemoCache {
    /// A memo cache that many tasks can share. Each key's value is computed at most once, even when
    /// several tasks ask for the same key at the same time.
    public actor Store<Key: Hashable & Sendable, Value: Sendable> {
        public init() {}

        /// The value for `key`. The first request for a key runs `compute`; requests that arrive while
        /// that computation is still running wait for its result instead of starting another; later
        /// requests get the stored value.
        public func value(for key: Key, compute: @escaping @Sendable (Key) async -> Value) async -> Value {
            // Write your solution here, then run:
            // swift test --filter CoalescingMemoCacheTests
            // This placeholder computes every time and stores nothing.
            return await compute(key)
        }

        /// How many keys have a finished, stored value.
        public var storedCount: Int {
            return 0
        }

        /// Removes `key`'s stored value, if it has one, so the next request computes it again.
        /// A computation still in progress isn't affected: it stores its result when it finishes.
        public func forget(_ key: Key) {
        }
    }
}
