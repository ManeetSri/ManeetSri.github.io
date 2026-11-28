// Kata: Single-flight request group (D14 · Single-flight request de-duplication)
import DesignKit

public enum ResilienceSingleFlight {
    /// Collapses concurrent calls for the same key into one run of the work: the first caller starts it,
    /// and everyone who asks for that key while it's running waits for the same result or error.
    /// Nothing is cached: once a run ends, the next call for its key starts a new one.
    public actor Group<Key: Hashable & Sendable, Value: Sendable> {
        public init() {}

        /// How many keys have work running right now
        public var inFlight: Int {
            0
        }

        /// Runs `work` for `key`, or joins the run already in progress for it. Cancelling one caller
        /// doesn't cancel work that other callers are waiting for.
        public func run(_ key: Key, _ work: @escaping @Sendable () async throws -> Value) async throws -> Value {
            // Write your solution here, then run:
            // swift test --filter ResilienceSingleFlightTests
            throw Unimplemented()
        }
    }
}
