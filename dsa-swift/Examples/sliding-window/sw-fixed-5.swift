// Generated from src/dsa/content/lessons/sliding-window/sw-fixed.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let temperatures = [10, 12, 9, 13, 16, 14, 11]
let k = 4
var windowSum = 0
var averages: [Double] = []
for right in 0..<temperatures.count {
    windowSum += temperatures[right]
    if right >= k {
        windowSum -= temperatures[right - k]
    }
    if right >= k - 1 {
        averages.append(Double(windowSum) / Double(k))
    }
}
print(averages)
