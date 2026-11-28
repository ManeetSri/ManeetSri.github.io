// Generated from src/dsa/content/lessons/math-basics/math-series-logs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let numbers = [3, 0, 4, 1, 5]
let n = numbers.count
print(n * (n + 1) / 2 - numbers.reduce(0, +))
