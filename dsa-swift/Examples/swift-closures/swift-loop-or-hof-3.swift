// Generated from src/dsa/content/lessons/swift-closures/swift-loop-or-hof.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let temperatures = [4, -2, 9, 0, -5, 7]

var lowest = temperatures[0]
var highest = temperatures[0]
var total = 0
var belowZero = 0
for t in temperatures {
    lowest = min(lowest, t)
    highest = max(highest, t)
    total += t
    if t < 0 {
        belowZero += 1
    }
}
print(lowest, highest, total, belowZero)
