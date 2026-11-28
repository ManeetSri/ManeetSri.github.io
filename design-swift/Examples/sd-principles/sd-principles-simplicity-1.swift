// Generated from src/dsa/design/content/lessons/sd-principles/sd-principles-simplicity.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

final class Selection {
    var photoIDs: [String] = []
}

struct GalleryState {
    var title: String
    let selection = Selection()      // a reference hidden inside a value
}

var current = GalleryState(title: "Holiday")
let undoSnapshot = current           // keep a copy for undo

current.title = "Holiday 2026"
current.selection.photoIDs.append("IMG_0042")

print("Current: \(current.title), \(current.selection.photoIDs)")
print("Undo:    \(undoSnapshot.title), \(undoSnapshot.selection.photoIDs)")
