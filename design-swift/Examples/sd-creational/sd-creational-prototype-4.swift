// Generated from src/dsa/design/content/lessons/sd-creational/sd-creational-prototype.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

struct Note: Identifiable, Equatable {
    let id: UUID
    var title: String
    var body: String
    var serverID: String?
    var isPinned: Bool

    // A copy keeps the id. A duplicate is a new entity that starts from this one's content.
    func duplicated(newID: UUID) -> Note {
        Note(id: newID, title: title + " copy", body: body, serverID: nil, isPinned: false)
    }
}

let original = Note(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!, title: "Packing", body: "Passport, charger", serverID: "n_93", isPinned: true)

let copy = original
let duplicate = original.duplicated(newID: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!)

print(copy.id == original.id, copy == original)
print(duplicate.id == original.id, duplicate.title, duplicate.serverID ?? "not synced yet", duplicate.isPinned)
