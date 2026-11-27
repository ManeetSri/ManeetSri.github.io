// Generated from src/dsa/content/lessons/math-basics/math-series-logs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var total = 0
for i in 1...100 {
    total += i
}
print(total, 100 * 101 / 2)

var sum = 0
for x in stride(from: 3, through: 39, by: 4) {
    sum += x
}
print(sum, (3 + 39) * 10 / 2)
