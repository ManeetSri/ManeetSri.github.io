// Generated from src/dsa/content/lessons/sliding-window/sw-min-size-subarray.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let items = [1, 4, 2, 2, 3, 1, 5]
let target = 8
var left = 0
var sum = 0
for right in 0..<items.count {
    sum += items[right]
    while sum >= target {
        print("[\(left)...\(right)] sum \(sum), length \(right - left + 1)")
        sum -= items[left]
        left += 1
    }
}
