// Generated from src/dsa/content/lessons/swift-control-flow/swift-while.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var n = 100
var steps = 0

while n > 1 {
    n /= 2
    steps += 1
}
print("Halved \(steps) times")
