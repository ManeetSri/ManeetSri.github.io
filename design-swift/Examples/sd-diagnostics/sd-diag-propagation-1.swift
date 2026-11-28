// Generated from src/dsa/design/content/lessons/sd-diagnostics/sd-diag-propagation.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

/// An error that can say what it is in one line, and what caused it
protocol ChainedError: Error {
    var summary: String { get }
    var cause: (any Error)? { get }
}

// Infrastructure wraps: the kind, plus the context only this layer knows
struct APIError: ChainedError {
    enum Kind: Equatable {
        case transport
        case status(Int)
        case decoding
    }
    let kind: Kind
    let endpoint: String
    let requestID: String?
    let cause: (any Error)?

    var summary: String { "APIError.\(kind) \(endpoint) request=\(requestID ?? "none")" }
}

// The feature translates into what its callers branch on, and keeps the cause for diagnostics
struct OrdersError: ChainedError {
    enum Kind: Equatable {
        case offline
        case notFound
        case unavailable
        case broken
    }
    let kind: Kind
    let cause: (any Error)?

    var summary: String { "OrdersError.\(kind)" }
}

/// One line for the log: the error, then each cause beneath it
func describeChain(_ error: any Error) -> String {
    var parts: [String] = []
    var next: (any Error)? = error
    while let current = next {
        switch current {
        case let chained as ChainedError:
            parts.append(chained.summary)
            next = chained.cause
        case let url as URLError:
            parts.append("URLError \(url.code.rawValue)")
            next = nil
        default:
            parts.append(String(describing: type(of: current)))
            next = nil
        }
    }
    return parts.joined(separator: " <- ")
}

func fetchOrder(id: Int) throws(APIError) -> String {
    // The transport timed out; the client wraps it with what it knows
    throw APIError(kind: .transport, endpoint: "/orders/\(id)", requestID: "r-7f3a", cause: URLError(.timedOut))
}

func order(id: Int) throws(OrdersError) -> String {
    do {
        return try fetchOrder(id: id)
    } catch {
        let kind: OrdersError.Kind = switch error.kind {
        case .transport: .unavailable
        case .status(404): .notFound
        case .status: .unavailable
        case .decoding: .broken
        }
        throw OrdersError(kind: kind, cause: error)
    }
}

// The view model handles it: one log line with the whole chain, one decision for the screen
do throws(OrdersError) {
    _ = try order(id: 42)
} catch {
    print("log: \(describeChain(error))")
    switch error.kind {
    case .offline, .unavailable: print("screen: Couldn't load your order. [Try again]")
    case .notFound: print("screen: This order no longer exists.")
    case .broken: print("screen: Something went wrong on our side. [Contact support]")
    }
}
