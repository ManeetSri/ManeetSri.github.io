// Kata: An ordering buffer (D35 · Ordering and delivery guarantees)
import DesignKit

public enum RealtimeSequenceBuffer {
    /// One message on a channel. The server numbers each channel's messages 1, 2, 3… with no gaps.
    public struct Message: Equatable, Sendable {
        public let seq: Int
        public let body: String

        public init(seq: Int, body: String) {
            self.seq = seq
            self.body = body
        }
    }

    /// What the app should do next
    public enum Action: Equatable, Sendable {
        /// Hand this message to the app. Messages come out in sequence order, each exactly once.
        case deliver(Message)
        /// Ask the server to send these sequence numbers again
        case resend(ClosedRange<Int>)
        /// Too far behind to catch up message by message: fetch a snapshot, then call `resume(after:at:)`
        case resync
    }

    /// Times are offsets from any fixed start: the app passes `clock.now - start`, tests pass durations.
    public struct Buffer: Sendable {
        /// The highest sequence number handed to the app so far
        public private(set) var lastDelivered: Int
        /// How many messages were dropped as duplicates
        public private(set) var duplicates = 0
        /// True between a `.resync` and the `resume(after:at:)` that ends it
        public var isResyncing: Bool { false }

        private let gapTimeout: Duration
        private let capacity: Int

        /// - Parameters:
        ///   - lastSeen: the last sequence number already applied (0 for a fresh channel)
        ///   - gapTimeout: how long a gap may stay open before asking for a resend, and between repeated asks
        ///   - capacity: the most messages that may wait behind a gap
        public init(after lastSeen: Int = 0, gapTimeout: Duration = .seconds(2), capacity: Int = 100) {
            lastDelivered = lastSeen
            self.gapTimeout = gapTimeout
            self.capacity = capacity
        }

        /// A message arrived
        public mutating func receive(_ message: Message, at now: Duration) -> [Action] {
            // Write your solution here, then run:
            // swift test --filter RealtimeSequenceBufferTests
            []
        }

        /// Called on a timer: asks for missing messages once a gap has waited long enough
        public mutating func tick(at now: Duration) -> [Action] {
            []
        }

        /// The app applied a snapshot that includes every message up to and including `snapshot`
        public mutating func resume(after snapshot: Int, at now: Duration) -> [Action] {
            []
        }
    }
}
