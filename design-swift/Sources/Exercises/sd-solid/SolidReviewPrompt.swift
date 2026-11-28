// Kata: A review prompt policy that owns its dependencies (D04 · Dependency inversion: the policy owns the abstraction)
import DesignKit
import Foundation

public enum SolidReviewPrompt {
    /// What the policy remembers between launches
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

    /// Owned by the policy: somewhere to keep its history. The app implements it over UserDefaults;
    /// `KeyValueHistoryStore` below is the same idea over DesignKit's in-memory store.
    public protocol HistoryStore: Sendable {
        func load() async -> History
        func save(_ history: History) async
    }

    /// Owned by the policy: the system's review prompt. The app implements it by calling StoreKit's
    /// `AppStore.requestReview(in:)` with the active window scene; tests count the calls.
    @MainActor public protocol ReviewRequesting {
        func requestReview()
    }

    /// The rules for when to ask for an App Store review. Knows nothing about UserDefaults or StoreKit.
    @MainActor public final class ReviewPromptPolicy {
        /// Ask only once the person has completed at least this many orders
        public static let ordersBeforeAsking = 3
        /// And at least this long (120 days) after the last time the app asked
        public static let minimumGap: TimeInterval = 120 * 86_400

        private let store: any HistoryStore
        private let requester: any ReviewRequesting
        private let appVersion: String
        private let now: @Sendable () -> Date
        private var hadProblem = false

        /// One policy per launch. `appVersion` is the marketing version (CFBundleShortVersionString);
        /// `now` tells the time, so tests can choose it.
        public init(store: any HistoryStore, requester: any ReviewRequesting, appVersion: String, now: @escaping @Sendable () -> Date) {
            self.store = store
            self.requester = requester
            self.appVersion = appVersion
            self.now = now
        }

        /// Something went wrong in this launch (a failed payment, an error screen): don't ask again
        /// until the next launch.
        public func noteProblem() {
        }

        /// Counts the order and asks for a review when every rule allows it. Returns whether it asked.
        public func orderCompleted() async -> Bool {
            // Write your solution here, then run:
            // swift test --filter SolidReviewPromptTests
            return false
        }
    }

    /// A detail that depends on the policy's abstraction: the history kept as JSON under `key` in a
    /// key-value store (a stand-in for UserDefaults).
    public struct KeyValueHistoryStore: HistoryStore {
        public static let key = "reviewPrompt.history"
        private let store: InMemoryKeyValueStore

        public init(_ store: InMemoryKeyValueStore) {
            self.store = store
        }

        /// The saved history, or a fresh one when nothing's saved or the data can't be read
        public func load() async -> History {
            return History()
        }

        public func save(_ history: History) async {
        }
    }
}
