// Reference solution: Queued likes outbox. The core makes every decision with plain values; the shell
// gathers the inputs, runs the effects through the closures it was given, and has almost no branches.
import Foundation

public enum QueuedLikesOutbox {
    public struct PendingLike: Equatable, Sendable {
        public let postID: String
        public var failures: Int

        public init(postID: String, failures: Int = 0) {
            self.postID = postID
            self.failures = failures
        }
    }

    public enum Outcome: Equatable, Sendable {
        case sent
        case failed
        case rejected
    }

    // MARK: Functional core

    public static func batch(from outbox: [PendingLike], limit: Int, maxFailures: Int) -> [PendingLike] {
        Array(outbox.lazy.filter { $0.failures < maxFailures }.prefix(max(0, limit)))
    }

    public static func applying(_ outcomes: [String: Outcome], to outbox: [PendingLike]) -> [PendingLike] {
        outbox.compactMap { like in
            switch outcomes[like.postID] {
            case .sent?, .rejected?:
                return nil
            case .failed?:
                var retried = like
                retried.failures += 1
                return retried
            case nil:
                return like
            }
        }
    }

    // MARK: Imperative shell

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

    public static func flush(_ dependencies: Dependencies, limit: Int = 5, maxFailures: Int = 3) async -> Int {
        guard dependencies.isOnline() else { return 0 }
        let outbox = await dependencies.load()
        let likes = batch(from: outbox, limit: limit, maxFailures: maxFailures)
        guard !likes.isEmpty else { return 0 }

        var outcomes: [String: Outcome] = [:]
        for like in likes {
            outcomes[like.postID] = await dependencies.send(like)
        }
        await dependencies.save(applying(outcomes, to: outbox))
        return outcomes.values.filter { $0 == .sent }.count
    }
}
