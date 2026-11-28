// Generated from src/dsa/content/lessons/swift-closures/swift-escaping.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var onSave: [() -> Void] = []

func whenSaved(_ callback: @escaping () -> Void) {
    onSave.append(callback)
}

whenSaved { print("Update the title bar") }
whenSaved { print("Show a tick") }
print("Callbacks registered: \(onSave.count)")

print("Saving...")
for callback in onSave {
    callback()
}
