// Kata: Typeahead search reducer (D07 · Reducers: state changes as pure functions)
import Foundation

public enum TypeaheadSearch {
    /// Everything the search screen shows
    public struct State: Equatable, Sendable {
        /// The trimmed query the screen is showing results for
        public var query = ""
        public var results: [String] = []
        public var isLoading = false
        public var errorMessage: String?
        /// The id of the newest search. It moves on by one whenever the query changes or the screen is
        /// cleared, so a response carrying any other id is stale.
        public var currentSearch = 0

        public init() {}
    }

    /// Why a search failed
    public enum Failure: Error, Equatable, Sendable {
        case offline
        case server(status: Int)
    }

    /// Everything that can happen to the screen: the user typing or clearing, and searches finishing
    public enum Action: Equatable, Sendable {
        case queryChanged(String)
        case searchFinished(id: Int, Result<[String], Failure>)
        case clearTapped
    }

    /// Work for the shell to do. The reducer describes it; it never does it.
    public enum Effect: Equatable, Sendable {
        case search(id: Int, query: String)
    }

    /// Queries shorter than this (after trimming) don't search
    public static let minimumQueryLength = 2

    /// Applies one action to the state and returns the effects the shell should run, in order
    public static func reduce(_ state: inout State, _ action: Action) -> [Effect] {
        // Write your solution here, then run:
        // swift test --filter TypeaheadSearchTests
        return []
    }
}
