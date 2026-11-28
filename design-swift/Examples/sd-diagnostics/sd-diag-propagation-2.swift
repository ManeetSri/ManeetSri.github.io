// Generated from src/dsa/design/content/lessons/sd-diagnostics/sd-diag-propagation.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

// Version 1 of the app
enum SyncError: Error {
    case offline
    case conflict
    case quotaExceeded
}

// Version 2 adds a case at the top
enum SyncErrorV2: Error {
    case unauthorised
    case offline
    case conflict
    case quotaExceeded
}

// What an Objective-C API, or a crash reporter's recordError, receives
print("v1 quotaExceeded code:", (SyncError.quotaExceeded as NSError).code)
print("v2 quotaExceeded code:", (SyncErrorV2.quotaExceeded as NSError).code)

// Stable codes and a domain you choose
enum StableSyncError: Int, Error, CustomNSError {
    case offline = 100
    case conflict = 200
    case quotaExceeded = 300
    case unauthorised = 400

    static var errorDomain: String { "com.example.notes.sync" }
    var errorUserInfo: [String: Any] { ["layer": "sync"] }
}

let stable = StableSyncError.quotaExceeded as NSError
print(stable.domain, stable.code, stable.userInfo["layer"] ?? "none")
