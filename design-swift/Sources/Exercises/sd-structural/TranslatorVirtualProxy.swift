// Kata: A lazy-loading proxy (D11 · Proxy: virtual, remote, protection and NSProxy)
import DesignKit
import Foundation

public enum TranslatorVirtualProxy {
    /// Anything that translates text: the real on-device model, or the proxy standing in for it
    public protocol Translating: Sendable {
        func translate(_ text: String) async throws -> String
    }

    /// Stands in for a translation model that's slow and memory-hungry to load. It loads the model
    /// the first time it's needed, shares one load between callers that arrive while it's loading,
    /// and lets the app free the model under memory pressure.
    public actor LazyTranslator: Translating {
        private let load: @Sendable () async throws -> any Translating

        /// - Parameter load: loads the real model; it may take seconds, and it may fail
        public init(load: @escaping @Sendable () async throws -> any Translating) {
            self.load = load
        }

        /// Whether the model is in memory right now (false while it's still loading)
        public var isLoaded: Bool {
            false
        }

        public func translate(_ text: String) async throws -> String {
            // Write your solution here, then run:
            // swift test --filter TranslatorVirtualProxyTests
            throw Unimplemented()
        }

        /// Frees a loaded model (on a memory warning, say); the next translation loads it again.
        /// A load that's in progress carries on.
        public func unload() {}
    }
}
