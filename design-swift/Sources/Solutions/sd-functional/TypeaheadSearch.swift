// Reference solution: Typeahead search reducer. Every rule is a plain state change, every side effect is
// returned as a value for the shell to run, and a response only counts if it answers the newest search.
import Foundation

public enum TypeaheadSearch {
    public struct State: Equatable, Sendable {
        public var query = ""
        public var results: [String] = []
        public var isLoading = false
        public var errorMessage: String?
        public var currentSearch = 0

        public init() {}
    }

    public enum Failure: Error, Equatable, Sendable {
        case offline
        case server(status: Int)
    }

    public enum Action: Equatable, Sendable {
        case queryChanged(String)
        case searchFinished(id: Int, Result<[String], Failure>)
        case clearTapped
    }

    public enum Effect: Equatable, Sendable {
        case search(id: Int, query: String)
    }

    public static let minimumQueryLength = 2

    public static func reduce(_ state: inout State, _ action: Action) -> [Effect] {
        switch action {
        case .queryChanged(let text):
            let query = text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard query != state.query else { return [] }
            state.query = query
            state.errorMessage = nil
            // A new id for every change, so a response to any earlier query is recognisably stale
            state.currentSearch += 1
            guard query.count >= minimumQueryLength else {
                state.results = []
                state.isLoading = false
                return []
            }
            state.isLoading = true
            return [.search(id: state.currentSearch, query: query)]

        case .searchFinished(let id, let result):
            guard id == state.currentSearch else { return [] }
            state.isLoading = false
            switch result {
            case .success(let results):
                state.results = results
            case .failure(.offline):
                state.errorMessage = "You're offline."
            case .failure(.server(let status)):
                state.errorMessage = "Search failed (\(status))."
            }
            return []

        case .clearTapped:
            let next = state.currentSearch + 1
            state = State()
            state.currentSearch = next
            return []
        }
    }
}
