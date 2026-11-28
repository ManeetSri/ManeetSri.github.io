// Generated from src/dsa/content/lessons/bs-on-answer/bsa-real-numbers.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var low = 0.0
var high = 1e18
var steps = 0
while high - low > 1e-9 && steps < 1_000 {      // the step limit is only a safety net
    let mid = (low + high) / 2
    if mid * mid >= 1e18 {
        high = mid
    } else {
        low = mid
    }
    steps += 1
}
print(steps, high - low, high)
