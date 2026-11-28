// Kata: Queued likes outbox (D07 · Functional core, imperative shell)
import Foundation

public enum QueuedLikesOutbox {
    /// A like that hasn't reached the server yet. Post ids are unique in the outbox.
    public struct PendingLike: Equatable, Sendable {
        public let postID: String
        /// How many times sending it has failed so far
        public var failures: Int

        public init(postID: String, failures: Int = 0) {
            self.postID = postID
            self.failures = failures
        }
    }

    /// What happened when the shell tried to send one like
    public enum Outcome: Equatable, Sendable {
        /// The server has it: drop it from the outbox
        case sent
        /// A network error or a 5xx: keep it, and count the failure
        case failed
        /// A 4xx, such as the post having been deleted: drop it, because retrying can't help
        case rejected
    }

    // MARK: Functional core: plain values in, plain values out

    /// The likes to send this time: in outbox order, skipping any that have already failed `maxFailures`
    /// times, and at most `limit` of them
    public static func batch(from outbox: [PendingLike], limit: Int, maxFailures: Int) -> [PendingLike] {
        // Write your solution here, then run:
        // swift test --filter QueuedLikesOutboxTests
        return []
    }

    /// The outbox after a flush: sent and rejected likes removed, failed ones with one more failure,
    /// likes that weren't tried left as they were, and the order kept
    public static func applying(_ outcomes: [String: Outcome], to outbox: [PendingLike]) -> [PendingLike] {
        return outbox
    }

    // MARK: Imperative shell: everything it touches arrives as a closure

    /// The outside world, as values. The app passes live closures (NWPathMonitor, a file, URLSession);
    /// tests pass closures that record what they were asked to do.
    public struct Dependencies: Sendable {
        public var isOnline: @Sendable () -> Bool
        public var load: @Sendable () async -> [PendingLike]
        public var send: @Sendable (PendingLike) async -> Outcome
        public var save: @Sendable ([PendingLike]) async -> Void

        public init(
            isOnline: @escaping @Sendable () -> Bool,
            load: @escaping @Sendable () async -> [PendingLike],
            send: @escaping @Sendable (PendingLike) async -> Outcome,
            save: @escaping @Sendable ([PendingLike]) async -> Void
        ) {
            self.isOnline = isOnline
            self.load = load
            self.send = send
            self.save = save
        }
    }

    /// Sends one batch from the outbox and saves what's left. Offline, it touches nothing. It sends the
    /// batch one like at a time, in order, saves the outbox once (and only if it sent anything), and
    /// returns how many likes reached the server.
    public static func flush(_ dependencies: Dependencies, limit: Int = 5, maxFailures: Int = 3) async -> Int {
        return 0
    }
}
