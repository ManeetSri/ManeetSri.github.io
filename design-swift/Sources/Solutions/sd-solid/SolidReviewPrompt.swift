// Reference solution: A review prompt policy that owns its dependencies. The rules live in the policy and
// talk only to the two protocols it declares; the key-value store adapter is a detail that depends on
// the policy's protocol, never the other way round.
import DesignKit
import Foundation

public enum SolidReviewPrompt {
    public struct History: Sendable, Equatable, Codable {
        public var completedOrders: Int
        public var lastPromptDate: Date?
        public var lastPromptVersion: String?

        public init(completedOrders: Int = 0, lastPromptDate: Date? = nil, lastPromptVersion: String? = nil) {
            self.completedOrders = completedOrders
            self.lastPromptDate = lastPromptDate
            self.lastPromptVersion = lastPromptVersion
        }
    }

    public protocol HistoryStore: Sendable {
        func load() async -> History
        func save(_ history: History) async
    }

    @MainActor public protocol ReviewRequesting {
        func requestReview()
    }

    @MainActor public final class ReviewPromptPolicy {
        public static let ordersBeforeAsking = 3
        public static let minimumGap: TimeInterval = 120 * 86_400

        private let store: any HistoryStore
        private let requester: any ReviewRequesting
        private let appVersion: String
        private let now: @Sendable () -> Date
        private var hadProblem = false

        public init(store: any HistoryStore, requester: any ReviewRequesting, appVersion: String, now: @escaping @Sendable () -> Date) {
            self.store = store
            self.requester = requester
            self.appVersion = appVersion
            self.now = now
        }

        public func noteProblem() {
            hadProblem = true
        }

        public func orderCompleted() async -> Bool {
            var history = await store.load()
            history.completedOrders += 1
            let date = now()
            let shouldAsk = !hadProblem
                && history.completedOrders >= Self.ordersBeforeAsking
                && history.lastPromptVersion != appVersion
                && history.lastPromptDate.map { date.timeIntervalSince($0) >= Self.minimumGap } ?? true
            if shouldAsk {
                requester.requestReview()
                history.lastPromptDate = date
                history.lastPromptVersion = appVersion
            }
            await store.save(history)
            return shouldAsk
        }
    }

    public struct KeyValueHistoryStore: HistoryStore {
        public static let key = "reviewPrompt.history"
        private let store: InMemoryKeyValueStore

        public init(_ store: InMemoryKeyValueStore) {
            self.store = store
        }

        public func load() async -> History {
            guard let data = await store.data(for: Self.key),
                  let history = try? JSONDecoder().decode(History.self, from: data) else { return History() }
            return history
        }

        public func save(_ history: History) async {
            await store.set(try? JSONEncoder().encode(history), for: Self.key)
        }
    }
}
