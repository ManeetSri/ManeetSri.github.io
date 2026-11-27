// Generated from src/dsa/content/lessons/swift-strings/swift-char-digit-conversion.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let n = 9045
print(String(n).compactMap { $0.wholeNumberValue })

var remaining = 9045
var digits: [Int] = []
while remaining > 0 {
    digits.append(remaining % 10)
    remaining /= 10
}
print(digits)
print(Array(digits.reversed()))
