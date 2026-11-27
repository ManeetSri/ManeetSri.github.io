// Generated from src/dsa/content/lessons/swift-collections/swift-choosing-collection.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var undoStack: [String] = []
undoStack.append("open file")
undoStack.append("type text")
undoStack.append("bold")

print("top: \(undoStack.last ?? "empty")")
while let action = undoStack.popLast() {
    print("undo \(action)")
}
