// Generated from src/dsa/design/content/lessons/sd-diagnostics/sd-diag-structured-logging.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

/// One structured event: a stable name, a level, and typed fields, inside an envelope every event shares
struct LogEvent: Encodable {
    enum Level: String, Encodable {
        case info, notice, error, fault
    }

    // The envelope: who, where, when, in which order
    let session: String
    let seq: Int
    let app: String
    let os: String
    // The event itself
    let event: String
    let level: Level
    let fields: [String: String]
}

let encoder = JSONEncoder()
encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]

let events = [
    LogEvent(session: "s-91c2", seq: 41, app: "5.2.0 (812)", os: "iOS 18.4", event: "orders.load_failed", level: .error,
             fields: ["kind": "unavailable", "endpoint": "/orders", "request_id": "r-7f3a", "attempts": "3"]),
    LogEvent(session: "s-91c2", seq: 42, app: "5.2.0 (812)", os: "iOS 18.4", event: "orders.cache_served", level: .info,
             fields: ["age_s": "5400", "count": "12"]),
]
for event in events {
    print(String(decoding: try encoder.encode(event), as: UTF8.self))
}
