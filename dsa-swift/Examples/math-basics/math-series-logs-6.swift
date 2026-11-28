// Generated from src/dsa/content/lessons/math-basics/math-series-logs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var m = 1_000_000
var halvings = 0
while m > 1 {
    m /= 2
    halvings += 1
}
print(halvings)
