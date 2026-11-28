// Reference solution: Testable review prompter. The rules are the same as in a `ReviewPrompter.shared`
// that reads UserDefaults.standard and Date(), but the store and the clock are passed in, so every test
// starts from its own state at a time it chooses. The prompter keeps no state of its own: it loads,
// changes and saves through the store, so two prompters over one store agree, as an app and its next
// launch must. `live(appVersion:)` is the one place that names the real UserDefaults and clock.
import Foundation

public enum CreationalReviewPrompt {
    public struct State: Codable, Equatable, Sendable {
        public var launches: Int
        public var firstLaunch: Date?
        public var lastPrompt: Date?
        public var lastPromptVersion: String?

        public init(launches: Int = 0, firstLaunch: Date? = nil, lastPrompt: Date? = nil, lastPromptVersion: String? = nil) {
            self.launches = launches
            self.firstLaunch = firstLaunch
            self.lastPrompt = lastPrompt
            self.lastPromptVersion = lastPromptVersion
        }
    }

    public protocol StateStore: AnyObject {
        func load() -> State
        func save(_ state: State)
    }

    public final class MemoryStore: StateStore {
        public private(set) var state: State

        public init(_ state: State = State()) {
            self.state = state
        }

        public func load() -> State { state }
        public func save(_ state: State) { self.state = state }
    }

    public final class DefaultsStore: StateStore {
        private let defaults: UserDefaults
        private let key: String

        public init(defaults: UserDefaults, key: String = "reviewPrompt") {
            self.defaults = defaults
            self.key = key
        }

        public func load() -> State {
            guard let data = defaults.data(forKey: key),
                  let state = try? JSONDecoder().decode(State.self, from: data) else { return State() }
            return state
        }

        public func save(_ state: State) {
            guard let data = try? JSONEncoder().encode(state) else { return }
            defaults.set(data, forKey: key)
        }
    }

    public struct Prompter {
        public static let minimumLaunches = 5
        public static let minimumDaysSinceFirstLaunch = 3.0
        public static let minimumDaysBetweenPrompts = 90.0

        private static let day: TimeInterval = 86_400

        private let store: any StateStore
        private let appVersion: String
        private let now: () -> Date

        public init(store: any StateStore, appVersion: String, now: @escaping () -> Date) {
            self.store = store
            self.appVersion = appVersion
            self.now = now
        }

        public static func live(appVersion: String) -> Prompter {
            Prompter(store: DefaultsStore(defaults: .standard), appVersion: appVersion, now: { Date() })
        }

        public func recordLaunch() {
            var state = store.load()
            state.launches += 1
            if state.firstLaunch == nil {
                state.firstLaunch = now()
            }
            store.save(state)
        }

        public func shouldPrompt() -> Bool {
            let state = store.load()
            let now = now()
            guard state.launches >= Self.minimumLaunches,
                  let firstLaunch = state.firstLaunch,
                  now.timeIntervalSince(firstLaunch) >= Self.minimumDaysSinceFirstLaunch * Self.day,
                  state.lastPromptVersion != appVersion else { return false }
            if let lastPrompt = state.lastPrompt {
                return now.timeIntervalSince(lastPrompt) >= Self.minimumDaysBetweenPrompts * Self.day
            }
            return true
        }

        public func recordPrompt() {
            var state = store.load()
            state.lastPrompt = now()
            state.lastPromptVersion = appVersion
            store.save(state)
        }
    }
}
