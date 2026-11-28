// Generated from src/dsa/design/content/lessons/sd-unidirectional/sd-udf-tca-scoping.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

struct Row: Identifiable {
    let id: Int
    let title: String
    var isDownloaded = false
}

func shelf() -> [Row] {
    [Row(id: 10, title: "Dune"), Row(id: 20, title: "Emma"), Row(id: 30, title: "Ulysses")]
}

func downloaded(_ rows: [Row]) -> [String] {
    rows.filter(\.isDownloaded).map(\.title)
}

// The download for Emma started when Emma was at index 1. Then the user deleted Dune.
var byIndex = shelf()
let emmaIndex = 1
byIndex.removeAll { $0.id == 10 }
byIndex[emmaIndex].isDownloaded = true   // the late answer, routed by position
print("by index, after deleting Dune:", downloaded(byIndex))

var byID = shelf()
let emmaID = 20
byID.removeAll { $0.id == 10 }
if let index = byID.firstIndex(where: { $0.id == emmaID }) { byID[index].isDownloaded = true }
print("by id, after deleting Dune:", downloaded(byID))

// Now the user deletes Emma herself before her download finishes
var gone = shelf()
gone.removeAll { $0.id == emmaID }
if let index = gone.firstIndex(where: { $0.id == emmaID }) { gone[index].isDownloaded = true }
print("by id, after deleting Emma:", downloaded(gone))
