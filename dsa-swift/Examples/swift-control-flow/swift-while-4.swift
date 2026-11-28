// Generated from src/dsa/content/lessons/swift-control-flow/swift-while.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var n = 1230
var reversed = 0

while n > 0 {
    reversed = reversed * 10 + n % 10
    n /= 10
}
print(reversed)
