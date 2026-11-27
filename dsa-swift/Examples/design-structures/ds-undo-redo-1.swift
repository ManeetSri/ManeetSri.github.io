// Generated from src/dsa/content/lessons/design-structures/ds-undo-redo.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct SnapshotHistory {
    private(set) var text = ""
    private var undoTexts: [String] = []           // the whole text before each edit
    private var redoTexts: [String] = []
    private(set) var charactersStored = 0

    mutating func edit(_ change: (inout String) -> Void) {
        undoTexts.append(text)
        charactersStored += text.count
        redoTexts.removeAll()
        change(&text)
    }

    mutating func undo() {
        guard let previous = undoTexts.popLast() else { return }
        redoTexts.append(text)
        text = previous
    }
}

let letters = Array("abcdefghijklmnopqrstuvwxyz")
var essay = SnapshotHistory()
for index in 0..<1_000 {
    essay.edit { $0.append(letters[index % 26]) }  // one keystroke, one edit
}
print("characters typed:", essay.text.count)
print("characters stored for undo:", essay.charactersStored)
for _ in 1...3 {
    essay.undo()
}
print("after 3 undos:", essay.text.count, essay.text.suffix(3))
