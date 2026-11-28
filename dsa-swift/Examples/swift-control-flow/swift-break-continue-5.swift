// Generated from src/dsa/content/lessons/swift-control-flow/swift-break-continue.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var n = 27
var steps = 0

while true {
    if n == 1 {
        break
    }
    n = n % 2 == 0 ? n / 2 : 3 * n + 1
    steps += 1
}
print("27 reaches 1 after \(steps) steps")
