// Reference solution: Lock-guarded request stats. LockedValue is a Mutex-shaped wrapper: an NSLock and a
// private value, reachable only inside withLock, which unlocks in a defer. RequestStats keeps all its
// figures in one LockedValue, so a summary is a consistent snapshot and drain reads and resets in a single
// critical section; the dispenser reserves tickets the same way. O(1) per call.

import Foundation

public enum LockedStatsRecorder {
    public final class LockedValue<Value>: @unchecked Sendable {
        private var value: Value
        private let lock = NSLock()

        public init(_ value: Value) { self.value = value }

        public func withLock<Result>(_ body: (inout Value) throws -> Result) rethrows -> Result {
            lock.lock()
            defer { lock.unlock() }
            return try body(&value)
        }
    }

    public struct Summary: Equatable, Sendable {
        public var requests: Int
        public var totalMilliseconds: Int
        public var slowest: Int
        public init(requests: Int = 0, totalMilliseconds: Int = 0, slowest: Int = 0) {
            self.requests = requests
            self.totalMilliseconds = totalMilliseconds
            self.slowest = slowest
        }
    }

    public final class RequestStats: Sendable {
        private let stats = LockedValue(Summary())

        public init() {}

        public func record(milliseconds: Int) {
            stats.withLock { stats in
                stats.requests += 1
                stats.totalMilliseconds += milliseconds
                stats.slowest = max(stats.slowest, milliseconds)
            }
        }

        public var summary: Summary { stats.withLock { $0 } }

        public func drain() -> Summary {
            stats.withLock { stats in
                let current = stats
                stats = Summary()
                return current
            }
        }
    }

    public final class TicketDispenser: Sendable {
        private let nextTicket: LockedValue<Int>

        public init(startingAt first: Int) { nextTicket = LockedValue(first) }

        public func next() -> Int {
            nextTicket.withLock { ticket in
                defer { ticket += 1 }
                return ticket
            }
        }

        public func next(batch count: Int) -> Range<Int> {
            nextTicket.withLock { ticket in
                let start = ticket
                ticket += count
                return start..<ticket
            }
        }
    }
}
