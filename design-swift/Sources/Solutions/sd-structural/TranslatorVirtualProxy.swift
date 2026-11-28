// Reference solution: A lazy-loading proxy. The proxy is a small state machine (idle, loading,
// loaded) kept on an actor. While a load is running, its Task is stored, so later callers await the
// same Task instead of starting another; a failed load goes back to idle, so the next call retries.
import Foundation

public enum TranslatorVirtualProxy {
    public protocol Translating: Sendable {
        func translate(_ text: String) async throws -> String
    }

    public actor LazyTranslator: Translating {
        private enum State {
            case idle
            case loading(Task<any Translating, any Error>)
            case loaded(any Translating)
        }

        private let load: @Sendable () async throws -> any Translating
        private var state: State = .idle

        public init(load: @escaping @Sendable () async throws -> any Translating) {
            self.load = load
        }

        public var isLoaded: Bool {
            if case .loaded = state { return true }
            return false
        }

        public func translate(_ text: String) async throws -> String {
            try await model().translate(text)
        }

        public func unload() {
            if case .loaded = state { state = .idle }
        }

        private func model() async throws -> any Translating {
            switch state {
            case .loaded(let model):
                return model
            case .loading(let task):
                return try await task.value
            case .idle:
                // Store the load before awaiting it: the actor takes other calls while this one waits
                let task = Task { try await load() }
                state = .loading(task)
                do {
                    let model = try await task.value
                    state = .loaded(model)
                    return model
                } catch {
                    state = .idle
                    throw error
                }
            }
        }
    }
}
