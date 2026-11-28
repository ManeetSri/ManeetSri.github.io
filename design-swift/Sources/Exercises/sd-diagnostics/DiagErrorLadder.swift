// Kata: Error ladder (D24 · Propagating and mapping errors across layers)
import Foundation

public enum DiagErrorLadder {
    /// What the transport layer reports
    public enum TransportError: Error, Equatable, Sendable {
        case notConnected
        case timedOut
        case cancelled
        /// A response arrived with a status outside 200–299. `retryAfter` is the Retry-After header in seconds.
        case status(Int, retryAfter: Int?)
        /// The body didn't decode into the expected type
        case undecodable
    }

    /// What the orders feature's callers switch on
    public enum OrdersError: Error, Equatable, Sendable {
        case cancelled
        case offline
        case unavailable(retryAfter: Int?)
        case sessionExpired
        case notFound
        case rejected(status: Int)
        case serverFault
        case contractBroken
    }

    /// Which words the screen shows. The view looks the key up in its String Catalog.
    public enum MessageKey: String, Equatable, Sendable {
        case offline
        case busy
        case signInAgain
        case notFound
        case generic
    }

    /// What happens next
    public enum Retry: Equatable, Sendable {
        case none
        case button
        case automatically(afterSeconds: Int)
        case whenOnline
        case signIn
    }

    /// Everything the screen needs to know about a failure
    public struct Presentation: Equatable, Sendable {
        public let message: MessageKey
        public let retry: Retry
        /// Whether to send a non-fatal report: true when the app itself is probably at fault
        public let report: Bool

        public init(message: MessageKey, retry: Retry, report: Bool) {
            self.message = message
            self.retry = retry
            self.report = report
        }
    }

    /// Rung one: what a transport failure means for orders
    public static func ordersError(for error: TransportError) -> OrdersError {
        // Write your solution here, then run:
        // swift test --filter DiagErrorLadderTests
        return .contractBroken
    }

    /// Runs a transport call and rethrows its failure in the feature's vocabulary
    public static func load<T>(_ operation: () async throws(TransportError) -> T) async throws(OrdersError) -> T {
        throw .contractBroken
    }

    /// Rung two: what the screen shows. `attempt` counts the attempts that have failed so far, starting at 1.
    /// Returns nil when nothing should be shown.
    public static func presentation(for error: OrdersError, attempt: Int) -> Presentation? {
        return nil
    }
}
