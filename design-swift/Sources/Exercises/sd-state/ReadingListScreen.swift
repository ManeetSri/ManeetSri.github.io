// Kata: Reading list screen state (D19 · View-state enums: loading, loaded, empty, error)
import Foundation

public enum ReadingListScreen {
    public struct Article: Equatable, Sendable {
        public let id: Int
        public let title: String

        public init(id: Int, title: String) {
            self.id = id
            self.title = title
        }
    }

    /// What the main area of the screen shows
    public enum Content: Equatable, Sendable {
        /// Nothing has been asked for yet
        case idle
        /// The first load is running, and there's nothing to show
        case loading
        /// The articles, in order
        case loaded([Article])
        /// A load worked, and there are no articles
        case empty
        /// The first load failed, and there's nothing to show
        case failed(message: String)
    }

    public struct State: Equatable, Sendable {
        public var content: Content
        /// A reload is running while the content stays on screen
        public var isRefreshing: Bool
        /// Why the last refresh failed, shown over the content, which stays
        public var banner: String?
        /// The id of the newest fetch. Answers to older fetches are ignored.
        public var latestRequest: Int

        public init(content: Content = .idle, isRefreshing: Bool = false, banner: String? = nil, latestRequest: Int = 0) {
            self.content = content
            self.isRefreshing = isRefreshing
            self.banner = banner
            self.latestRequest = latestRequest
        }
    }

    public enum Event: Equatable, Sendable {
        case appeared
        case refreshPulled
        case retryTapped
        case bannerDismissed
        case fetchSucceeded(request: Int, articles: [Article])
        case fetchFailed(request: Int, message: String)
    }

    /// Work the reducer asks the view model to do. It never does the work itself.
    public enum Effect: Equatable, Sendable {
        case fetch(request: Int)
    }

    /// Applies one event to the state, and returns the fetch to start, if any
    public static func reduce(_ state: inout State, _ event: Event) -> Effect? {
        // Write your solution here, then run:
        // swift test --filter ReadingListScreenTests
        return nil
    }
}
