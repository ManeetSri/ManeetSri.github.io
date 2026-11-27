// Generated from src/dsa/content/lessons/swift-control-flow/swift-while.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var balance = 100
var years = 0

while balance < 200 {
    balance = balance * 110 / 100
    years += 1
}
print("After \(years) years the balance is \(balance)")
