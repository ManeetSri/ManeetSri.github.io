// Generated from src/dsa/content/lessons/math-basics/math-series-logs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var capacity = 1
var count = 0
var copies = 0
for _ in 0..<1000 {
    if count == capacity {
        copies += count
        capacity *= 2
    }
    count += 1
}
print(copies, capacity)
