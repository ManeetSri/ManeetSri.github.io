// Generated from src/dsa/content/lessons/swift-control-flow/swift-nested-loops.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let n = 4
for row in 1...n {
    var line = ""
    for _ in 0..<(n - row) {
        line += "."
    }
    for _ in 1...row {
        line += "#"
    }
    print(line)
}
