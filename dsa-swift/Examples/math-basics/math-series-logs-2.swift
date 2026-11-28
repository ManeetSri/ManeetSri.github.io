// Generated from src/dsa/content/lessons/math-basics/math-series-logs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let n = 10
var pairs = 0
for i in 0..<n {
    for _ in (i + 1)..<n {
        pairs += 1
    }
}
print(pairs)
