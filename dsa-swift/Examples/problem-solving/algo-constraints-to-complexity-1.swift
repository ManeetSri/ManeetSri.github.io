// Generated from src/dsa/content/lessons/problem-solving/algo-constraints-to-complexity.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var n = 1_000_000
var halvings = 0
while n > 1 {
    n /= 2
    halvings += 1
}
print(halvings)
