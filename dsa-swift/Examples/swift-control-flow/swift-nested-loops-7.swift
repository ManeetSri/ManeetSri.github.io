// Generated from src/dsa/content/lessons/swift-control-flow/swift-nested-loops.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var total = 0
for i in 1...3 {
    for j in 1...i {
        total += j
        print("i = \(i), j = \(j), total = \(total)")
    }
}
