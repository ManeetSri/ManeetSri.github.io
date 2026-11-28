// Generated from src/dsa/design/content/lessons/sd-app-runtime/sd-runtime-restoration.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

// Where the user was, not what they had: ids that point into the app's own store
struct RestorationSnapshot: Codable, Equatable {
    static let currentVersion = 2
    var version = currentVersion
    var tab: String
    var openOrderID: String?
}

enum Restoration: Equatable {
    case restore(RestorationSnapshot)
    case startFresh(String)
}

func restoration(from data: Data?, existingOrders: Set<String>) -> Restoration {
    guard let data else { return .startFresh("nothing was saved") }
    guard let saved = try? JSONDecoder().decode(RestorationSnapshot.self, from: data) else {
        return .startFresh("the saved state is unreadable")
    }
    guard saved.version == RestorationSnapshot.currentVersion else {
        return .startFresh("it was saved by version \(saved.version)")
    }
    var snapshot = saved
    // The order may have been deleted on another device since: fall back to the list
    if let id = snapshot.openOrderID, !existingOrders.contains(id) {
        snapshot.openOrderID = nil
    }
    return .restore(snapshot)
}

func describe(_ result: Restoration) -> String {
    switch result {
    case .restore(let snapshot):
        "restore the \(snapshot.tab) tab, " + (snapshot.openOrderID.map { "showing order \($0)" } ?? "showing the list")
    case .startFresh(let reason):
        "start fresh: \(reason)"
    }
}

let encoder = JSONEncoder()
encoder.outputFormatting = .sortedKeys
let saved = try encoder.encode(RestorationSnapshot(tab: "orders", openOrderID: "A17"))
print("saved \(saved.count) bytes: \(String(decoding: saved, as: UTF8.self))")

let oldVersion = try encoder.encode(RestorationSnapshot(version: 1, tab: "orders", openOrderID: "A17"))
let cases: [(String, Data?, Set<String>)] = [
    ("first launch", nil, ["A17"]),
    ("killed while suspended", saved, ["A17", "B02"]),
    ("order deleted meanwhile", saved, ["B02"]),
    ("after an app update", oldVersion, ["A17"]),
    ("corrupted", Data("{".utf8), ["A17"]),
]
for (name, data, orders) in cases {
    print("\(name): \(describe(restoration(from: data, existingOrders: orders)))")
}
