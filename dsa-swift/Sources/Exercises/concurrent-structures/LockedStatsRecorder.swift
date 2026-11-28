// Problem: Lock-guarded request stats (M70 · Mutex and atomics in Swift 6)

import Foundation

public enum LockedStatsRecorder {
    /// A lock that owns its value, like Swift 6's Mutex, built on NSLock for macOS 14.
    public final class LockedValue<Value>: @unchecked Sendable {
        // Write your solution here, then run:
        // swift test --filter LockedStatsRecorderTests
        // This placeholder runs `body` on a throwaway copy, so nothing is shared yet (and nothing sticks).
        private let value: Value

        /// Creates a lock that owns `value`.
        public init(_ value: Value) {
            self.value = value
        }

        /// Locks, runs `body` with the value as inout, unlocks (even if `body` throws), and returns
        /// what `body` returned.
        public func withLock<Result>(_ body: (inout Value) throws -> Result) rethrows -> Result {
            var copy = value
            return try body(&copy)
        }
    }

    /// Request statistics at one moment.
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

    /// Request statistics that many tasks record into at once.
    public final class RequestStats: Sendable {
        /// Creates empty statistics.
        public init() {}

        /// Adds one request that took `milliseconds`.
        public func record(milliseconds: Int) {
        }

        /// The number of requests, their total time and the slowest, all from the same moment.
        public var summary: Summary {
            return Summary(requests: -1)
        }

        /// Returns the summary and resets everything to zero, in one step.
        public func drain() -> Summary {
            return Summary(requests: -1)
        }
    }

    /// Hands out unique, increasing ticket numbers to many tasks at once.
    public final class TicketDispenser: Sendable {
        /// The first ticket handed out will be `first`.
        public init(startingAt first: Int) {}

        /// The next ticket number.
        public func next() -> Int {
            return 0
        }

        /// Reserves `count` consecutive tickets in one step.
        public func next(batch count: Int) -> Range<Int> {
            return 0..<0
        }
    }
}
