// Generated from src/dsa/content/lessons/swift-control-flow/swift-while.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var n = 4721
var digitSum = 0

while n > 0 {
    let lastDigit = n % 10
    digitSum += lastDigit
    n /= 10
}
print("Digit sum: \(digitSum)")
