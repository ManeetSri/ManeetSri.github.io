// Generated from src/dsa/content/lessons/swift-closures/swift-loop-or-hof.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let temperatures = [4, -2, 9, 0, -5, 7]

let lowest = temperatures.min() ?? 0
let highest = temperatures.max() ?? 0
let total = temperatures.reduce(0, +)
let belowZero = temperatures.filter { $0 < 0 }.count
print(lowest, highest, total, belowZero)
