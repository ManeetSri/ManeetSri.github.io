// Kata: Circuit breaker (D14 · Circuit breakers and bulkheads)
import DesignKit
import Foundation

public enum ResilienceCircuitBreaker {
    /// Where the breaker is in its cycle
    public enum State: Equatable, Sendable {
        /// Calls go through, and consecutive failures are counted
        case closed
        /// Calls fail at once with `CircuitOpen`, without running, until the cooldown has passed
        case open
        /// The cooldown has passed (or a trial is running): one trial call decides what happens next
        case halfOpen
    }

    /// What `run` throws, without running the operation, when the breaker turns a call away
    public struct CircuitOpen: Error, Equatable, Sendable {
        public init() {}
    }

    /// Guards one dependency. After `failureThreshold` failures in a row it opens for `cooldown`, then lets
    /// one trial call through: success closes it, failure opens it for another full cooldown.
    /// `CancellationError` and `URLError(.cancelled)` aren't failures: the caller gave up, the server didn't.
    public actor Breaker<C: Clock> where C.Duration == Duration {
        public init(failureThreshold: Int, cooldown: Duration, clock: C) {
            // Write your solution here, then run:
            // swift test --filter ResilienceCircuitBreakerTests
        }

        /// The state as of `clock.now`: an open breaker whose cooldown has passed reports `.halfOpen`
        public var state: State {
            .closed
        }

        /// Runs `operation` if the breaker allows it, and records how it went
        public func run<Value: Sendable>(_ operation: @Sendable () async throws -> Value) async throws -> Value {
            throw Unimplemented()
        }
    }
}
