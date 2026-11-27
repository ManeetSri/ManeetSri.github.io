// Generated from src/dsa/content/lessons/swift-collections/swift-collections-are-values.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var history: [[Int]] = []
var state = [0, 0, 0]

for step in 0..<3 {
    state[step] = 1
    history.append(state)
}

for snapshot in history {
    print(snapshot)
}
