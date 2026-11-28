// Reference solution: Reading list screen state. A pure reducer: each event either moves the screen to
// its next state or is ignored, and the only effect is a numbered fetch. The number is what lets an
// answer that arrives late, after a timeout and a retry, be recognised and dropped.
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

    public enum Content: Equatable, Sendable {
        case idle
        case loading
        case loaded([Article])
        case empty
        case failed(message: String)
    }

    public struct State: Equatable, Sendable {
        public var content: Content
        public var isRefreshing: Bool
        public var banner: String?
        public var latestRequest: Int

        public init(content: Content = .idle, isRefreshing: Bool = false, banner: String? = nil, latestRequest: Int = 0) {
            self.content = content
            self.isRefreshing = isRefreshing
            self.banner = banner
            self.latestRequest = latestRequest
        }

        /// Articles, or the empty state: something a refresh can keep on screen
        var hasContent: Bool {
            switch content {
            case .loaded, .empty: true
            case .idle, .loading, .failed: false
            }
        }

        /// A fetch is running and its answer should change the screen
        var isWaiting: Bool { content == .loading || isRefreshing }
    }

    public enum Event: Equatable, Sendable {
        case appeared
        case refreshPulled
        case retryTapped
        case bannerDismissed
        case fetchSucceeded(request: Int, articles: [Article])
        case fetchFailed(request: Int, message: String)
    }

    public enum Effect: Equatable, Sendable {
        case fetch(request: Int)
    }

    public static func reduce(_ state: inout State, _ event: Event) -> Effect? {
        switch event {
        case .appeared:
            guard state.content == .idle else { return nil }
            state.content = .loading
            return nextFetch(&state)

        case .retryTapped:
            guard case .failed = state.content else { return nil }
            state.content = .loading
            return nextFetch(&state)

        case .refreshPulled:
            guard state.hasContent, !state.isRefreshing else { return nil }
            state.isRefreshing = true
            state.banner = nil
            return nextFetch(&state)

        case .bannerDismissed:
            state.banner = nil
            return nil

        case let .fetchSucceeded(request, articles):
            guard request == state.latestRequest, state.isWaiting else { return nil }
            state.content = articles.isEmpty ? .empty : .loaded(articles)
            state.isRefreshing = false
            state.banner = nil
            return nil

        case let .fetchFailed(request, message):
            guard request == state.latestRequest, state.isWaiting else { return nil }
            if state.hasContent {
                state.isRefreshing = false
                state.banner = message
            } else {
                state.content = .failed(message: message)
            }
            return nil
        }
    }

    private static func nextFetch(_ state: inout State) -> Effect {
        state.latestRequest += 1
        return .fetch(request: state.latestRequest)
    }
}
