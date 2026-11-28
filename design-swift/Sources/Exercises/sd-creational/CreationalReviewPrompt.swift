// Kata: Testable review prompter (D10 · Why to avoid singletons, and testable alternatives)
import Foundation

public enum CreationalReviewPrompt {
    /// Everything the prompter remembers between launches
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

    /// Where the state lives. The prompter loads it at the start of every call and saves any change.
    public protocol StateStore: AnyObject {
        func load() -> State
        func save(_ state: State)
    }

    /// Keeps the state in memory, for tests and previews. Already written.
    public final class MemoryStore: StateStore {
        public private(set) var state: State

        public init(_ state: State = State()) {
            self.state = state
        }

        public func load() -> State { state }
        public func save(_ state: State) { self.state = state }
    }

    /// Keeps the state in the UserDefaults it's given, as JSON data under `key`
    public final class DefaultsStore: StateStore {
        public init(defaults: UserDefaults, key: String = "reviewPrompt") {}

        /// The saved state, or a fresh `State()` if nothing readable is saved
        public func load() -> State {
            // Write your solution here, then run:
            // swift test --filter CreationalReviewPromptTests
            State()
        }

        public func save(_ state: State) {}
    }

    /// Decides when to ask for an App Store review. Its store and clock are injected, so tests control both.
    public struct Prompter {
        public static let minimumLaunches = 5
        public static let minimumDaysSinceFirstLaunch = 3.0
        public static let minimumDaysBetweenPrompts = 90.0

        public init(store: any StateStore, appVersion: String, now: @escaping () -> Date) {}

        /// The prompter the app uses: state in UserDefaults.standard, time from the system clock.
        /// Called once, at the composition root.
        public static func live(appVersion: String) -> Prompter {
            Prompter(store: MemoryStore(), appVersion: appVersion, now: { Date() })
        }

        /// Counts a launch, and remembers when the first one happened
        public func recordLaunch() {}

        /// Whether now is a good moment to ask for a review
        public func shouldPrompt() -> Bool {
            false
        }

        /// Remembers that the user was just asked, and in which app version
        public func recordPrompt() {}
    }
}
