// Generated from src/dsa/content/lessons/swift-closures/swift-capturing.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var level = 1

let live = { print("live: \(level)") }
let snapshot = { [level] in print("snapshot: \(level)") }

level = 5
live()
snapshot()
