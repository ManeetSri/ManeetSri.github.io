// Generated from src/dsa/content/lessons/math-basics/math-divisors.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let limit = 12
var counts = Array(repeating: 0, count: limit + 1)
for d in 1...limit {
    for multiple in stride(from: d, through: limit, by: d) {
        counts[multiple] += 1
    }
}
print(Array(counts[1...]))
