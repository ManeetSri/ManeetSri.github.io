// Generated from src/dsa/content/lessons/fast-swift/fs-benchmarking.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let samples = [4.1, 4.0, 4.3, 4.2, 19.7, 4.1, 4.0, 4.4, 4.1, 4.2, 4.0, 4.3, 4.1, 4.2, 4.1]
let sorted = samples.sorted()
let mean = samples.reduce(0, +) / Double(samples.count)
print("fastest:", sorted[0])
print("median:", sorted[sorted.count / 2])
print("mean:", (mean * 100).rounded() / 100)
print("slowest:", sorted[sorted.count - 1])
