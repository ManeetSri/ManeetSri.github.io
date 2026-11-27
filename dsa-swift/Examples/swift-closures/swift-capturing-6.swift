// Generated from src/dsa/content/lessons/swift-closures/swift-capturing.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var actions: [() -> Void] = []

for number in 1...3 {
    actions.append { print("Action \(number)") }
}

for action in actions {
    action()
}
