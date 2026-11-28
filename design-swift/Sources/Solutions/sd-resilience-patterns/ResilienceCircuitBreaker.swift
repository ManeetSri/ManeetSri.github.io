// Reference solution: Circuit breaker. One enum holds the whole state, so the actor can't be "open with a
// failure count" or "closed with a trial running". Every check and change happens between suspension
// points, so concurrent calls can't slip past a decision another call is in the middle of making.
import Foundation

public enum ResilienceCircuitBreaker {
    public enum State: Equatable, Sendable {
        case closed
        case open
        case halfOpen
    }

    public struct CircuitOpen: Error, Equatable, Sendable {
        public init() {}
    }

    public actor Breaker<C: Clock> where C.Duration == Duration {
        private enum Phase {
            /// Calls go through; `failures` in a row so far
            case closed(failures: Int)
            /// Calls are turned away until `until`; after that, the next call becomes the trial
            case open(until: C.Instant)
            /// A trial call is running, and every other call is turned away until it ends
            case trial
        }

        private let failureThreshold: Int
        private let cooldown: Duration
        private let clock: C
        private var phase = Phase.closed(failures: 0)

        public init(failureThreshold: Int, cooldown: Duration, clock: C) {
            self.failureThreshold = max(1, failureThreshold)
            self.cooldown = cooldown
            self.clock = clock
        }

        public var state: State {
            switch phase {
            case .closed: .closed
            case .open(let until): clock.now >= until ? .halfOpen : .open
            case .trial: .halfOpen
            }
        }

        public func run<Value: Sendable>(_ operation: @Sendable () async throws -> Value) async throws -> Value {
            switch phase {
            case .closed:
                return try await runClosed(operation)
            case .open(let until):
                guard clock.now >= until else { throw CircuitOpen() }
                phase = .trial
                return try await runTrial(operation)
            case .trial:
                throw CircuitOpen()
            }
        }

        private func runClosed<Value: Sendable>(_ operation: @Sendable () async throws -> Value) async throws -> Value {
            do {
                let value = try await operation()
                // Another call may have opened the breaker while this one was running; leave that decision alone
                if case .closed = phase { phase = .closed(failures: 0) }
                return value
            } catch {
                if Self.counts(error), case .closed(let failures) = phase {
                    phase = failures + 1 >= failureThreshold
                        ? .open(until: clock.now.advanced(by: cooldown))
                        : .closed(failures: failures + 1)
                }
                throw error
            }
        }

        private func runTrial<Value: Sendable>(_ operation: @Sendable () async throws -> Value) async throws -> Value {
            do {
                let value = try await operation()
                phase = .closed(failures: 0)
                return value
            } catch {
                // A cancelled trial proves nothing, so the next call may try again straight away
                phase = .open(until: Self.counts(error) ? clock.now.advanced(by: cooldown) : clock.now)
                throw error
            }
        }

        /// The caller giving up says nothing about the dependency's health
        private static func counts(_ error: any Error) -> Bool {
            if error is CancellationError { return false }
            if let urlError = error as? URLError, urlError.code == .cancelled { return false }
            return true
        }
    }
}
