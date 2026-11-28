// Generated from src/dsa/design/content/lessons/sd-diagnostics/sd-diag-error-taxonomy.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

enum FailureKind: String {
    case cancelled = "stop quietly"
    case recoverable = "recover in code"
    case userFacing = "tell the user"
    case bug = "report a bug"
}

// A feature's own errors, each with the kind its callers need
enum NoteSaveError: Error {
    case offline
    case serverBusy(retryAfterSeconds: Int)
    case storageFull
    case titleTooLong(limit: Int)
    case corruptDraft

    var kind: FailureKind {
        switch self {
        case .offline, .serverBusy: .recoverable
        case .storageFull, .titleTooLong: .userFacing
        case .corruptDraft: .bug
        }
    }
}

// Errors from frameworks, sorted once at the edge
func classify(_ error: any Error) -> FailureKind {
    switch error {
    case is CancellationError:
        return .cancelled
    case let error as NoteSaveError:
        return error.kind
    case let error as URLError:
        switch error.code {
        case .cancelled: return .cancelled
        case .timedOut, .networkConnectionLost, .notConnectedToInternet, .cannotConnectToHost: return .recoverable
        case .dataNotAllowed: return .userFacing    // mobile data is switched off
        default: return .bug
        }
    case let error as CocoaError where error.code == .fileWriteOutOfSpace:
        return .userFacing
    case is DecodingError:
        return .bug                                  // our own API broke its contract
    default:
        return .bug                                  // unknown: a gap in the taxonomy
    }
}

let failures: [(String, any Error)] = [
    ("left the screen", CancellationError()),
    ("train tunnel", URLError(.notConnectedToInternet)),
    ("mobile data off", URLError(.dataNotAllowed)),
    ("disk full", CocoaError(.fileWriteOutOfSpace)),
    ("title 300 chars", NoteSaveError.titleTooLong(limit: 200)),
    ("draft unreadable", NoteSaveError.corruptDraft),
]
for (what, error) in failures {
    print("\(what): \(classify(error).rawValue)")
}
