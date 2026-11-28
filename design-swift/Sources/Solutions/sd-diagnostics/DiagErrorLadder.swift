// Reference solution: Error ladder. Two pure mappings and a typed-throwing wrapper. The transport error
// becomes the feature's error by what it means for orders; the feature's error becomes words and a
// retry decision by what the user (or the code) can do about it. Each rung only knows the one below.
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

    /// Statuses that mean "busy or briefly unreachable: try again later"
    private static let transientStatuses: Set<Int> = [408, 429, 502, 503, 504]

    public static func ordersError(for error: TransportError) -> OrdersError {
        switch error {
        case .notConnected:
            return .offline
        case .timedOut:
            return .unavailable(retryAfter: nil)
        case .cancelled:
            return .cancelled
        case .undecodable:
            return .contractBroken
        case .status(let code, let retryAfter):
            switch code {
            case 401: return .sessionExpired
            case 404, 410: return .notFound
            case _ where transientStatuses.contains(code): return .unavailable(retryAfter: retryAfter)
            case 400...499: return .rejected(status: code)
            case 500...599: return .serverFault
            default: return .contractBroken      // a 1xx–3xx, or nonsense, reported as a failure
            }
        }
    }

    /// Runs a transport call and rethrows its failure in the feature's vocabulary
    public static func load<T>(_ operation: () async throws(TransportError) -> T) async throws(OrdersError) -> T {
        do {
            return try await operation()
        } catch {
            throw ordersError(for: error)
        }
    }

    /// `attempt` counts the attempts that have failed so far, starting at 1
    public static func presentation(for error: OrdersError, attempt: Int) -> Presentation? {
        let attempt = max(1, attempt)
        switch error {
        case .cancelled:
            return nil
        case .offline:
            return Presentation(message: .offline, retry: .whenOnline, report: false)
        case .unavailable(let retryAfter):
            guard attempt < 3 else { return Presentation(message: .busy, retry: .button, report: false) }
            let backoff = 1 << min(attempt, 6)          // 2, 4… seconds when the server gave no hint
            let delay = min(60, max(1, retryAfter ?? backoff))
            return Presentation(message: .busy, retry: .automatically(afterSeconds: delay), report: false)
        case .sessionExpired:
            return Presentation(message: .signInAgain, retry: .signIn, report: false)
        case .notFound:
            return Presentation(message: .notFound, retry: .none, report: false)
        case .rejected:
            return Presentation(message: .generic, retry: .none, report: true)
        case .serverFault:
            return Presentation(message: .generic, retry: .button, report: false)
        case .contractBroken:
            return Presentation(message: .generic, retry: .none, report: true)
        }
    }
}
