// Generated from src/dsa/content/lessons/math-basics/math-pigeonhole.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var value = 7
var seen: [Int] = []
while !seen.contains(value) {
    seen.append(value)
    value = value * 7 % 100
}
print(seen, value)
