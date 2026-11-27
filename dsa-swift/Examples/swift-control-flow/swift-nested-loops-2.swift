// Generated from src/dsa/content/lessons/swift-control-flow/swift-nested-loops.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

for row in 1...4 {
    var line = ""
    for _ in 1...row {
        line += "*"
    }
    print(line)
}
