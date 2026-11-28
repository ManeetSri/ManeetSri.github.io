// Generated from src/dsa/design/content/lessons/sd-behavioural-1/sd-behavioural-command.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

enum ReadingAction: Codable, Equatable {
    case save(articleID: String)
    case unsave(articleID: String)
    case highlight(articleID: String, text: String)
}

/// Actions taken offline, kept to send later. Because they're values, the outbox can inspect them.
struct Outbox {
    private(set) var pending: [ReadingAction] = []

    mutating func add(_ action: ReadingAction) {
        // Saving then unsaving the same article cancels out: neither needs sending
        if case .unsave(let id) = action, let index = pending.lastIndex(of: .save(articleID: id)) {
            pending.remove(at: index)
        } else {
            pending.append(action)
        }
    }
}

var outbox = Outbox()
outbox.add(.save(articleID: "a1"))
outbox.add(.highlight(articleID: "a1", text: "Make it work"))
outbox.add(.save(articleID: "a2"))
outbox.add(.unsave(articleID: "a2"))

let encoder = JSONEncoder()
encoder.outputFormatting = .sortedKeys
let saved = try encoder.encode(outbox.pending)
print(String(decoding: saved, as: UTF8.self))
let restored = try JSONDecoder().decode([ReadingAction].self, from: saved)
print(restored == outbox.pending ? "Restored \(restored.count) actions" : "Mismatch")
