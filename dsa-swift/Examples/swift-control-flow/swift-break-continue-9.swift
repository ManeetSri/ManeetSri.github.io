// Generated from src/dsa/content/lessons/swift-control-flow/swift-break-continue.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let commands = ["go", "go", "stop", "go"]
var moves = 0

loop: for command in commands {
    switch command {
    case "go":
        moves += 1
    case "stop":
        break loop
    default:
        break
    }
}
print("Moves before stopping: \(moves)")
