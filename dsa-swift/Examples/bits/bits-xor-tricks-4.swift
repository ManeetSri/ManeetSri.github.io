// Generated from src/dsa/content/lessons/bits/bits-xor-tricks.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var running = 0
var values: [Int] = []
for n in 0...11 {
    running ^= n
    values.append(running)
}
print(values)
