// Generated from src/dsa/content/lessons/swift-strings/swift-split-trim.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let command = "move 10 20 fast"
let parts = command.split(separator: " ", maxSplits: 1)
print(parts)
