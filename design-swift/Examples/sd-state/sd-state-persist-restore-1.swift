// Generated from src/dsa/design/content/lessons/sd-state/sd-state-persist-restore.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

enum Tab: String, Codable {
    case inbox, search, settings
}

/// What one window needs to look the same after a relaunch: small, and ids rather than objects
struct WindowSnapshot: Codable {
    static let currentVersion = 2

    var version = WindowSnapshot.currentVersion
    var tab = Tab.inbox
    var searchText = ""
    var openThreadID: String?

    /// Never crash on restore: anything unreadable or from another version gives a fresh window
    static func restore(from data: Data?, existingThreads: Set<String>) -> WindowSnapshot {
        guard let data,
              let snapshot = try? JSONDecoder().decode(WindowSnapshot.self, from: data),
              snapshot.version == currentVersion
        else { return WindowSnapshot() }

        var restored = snapshot
        if let id = restored.openThreadID, !existingThreads.contains(id) {
            restored.openThreadID = nil   // deleted since it was saved: show the list instead
        }
        return restored
    }
}

let threads: Set<String> = ["t1", "t2"]
let saved = [
    ("Saved normally", #"{"version":2,"tab":"search","searchText":"invoice","openThreadID":"t2"}"#),
    ("Thread deleted since", #"{"version":2,"tab":"inbox","searchText":"","openThreadID":"t9"}"#),
    ("Saved by an older version", #"{"version":1,"tab":"search","searchText":"invoice"}"#),
    ("A tab this build doesn't have", #"{"version":2,"tab":"archive","searchText":""}"#),
]
for (label, json) in saved {
    let window = WindowSnapshot.restore(from: Data(json.utf8), existingThreads: threads)
    print("\(label): \(window.tab), \"\(window.searchText)\", thread \(window.openThreadID ?? "none")")
}
