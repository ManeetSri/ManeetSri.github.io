// Generated from src/dsa/content/lessons/bs-on-answer/bsa-real-numbers.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var low = 0.0
var high = 2.0
for step in 1...8 {
    let mid = (low + high) / 2
    if mid * mid * mid >= 2 {
        high = mid
    } else {
        low = mid
    }
    print("step \(step): [\(low), \(high)]")
}
