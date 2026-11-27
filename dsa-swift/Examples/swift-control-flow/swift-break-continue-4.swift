// Generated from src/dsa/content/lessons/swift-control-flow/swift-break-continue.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var total = 0
for n in 1...20 where n % 3 == 0 {
    total += n
}
print(total)
