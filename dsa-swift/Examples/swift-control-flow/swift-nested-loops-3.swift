// Generated from src/dsa/content/lessons/swift-control-flow/swift-nested-loops.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

for row in stride(from: 4, through: 1, by: -1) {
    var line = ""
    for column in 1...row {
        line += "\(column)"
    }
    print(line)
}
