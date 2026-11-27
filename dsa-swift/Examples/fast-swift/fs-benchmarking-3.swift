// Generated from src/dsa/content/lessons/fast-swift/fs-benchmarking.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let sizes = [10_000, 20_000, 40_000, 80_000]
let medians = [1.9, 7.8, 31.5, 125.0]       // median milliseconds, from the harness
for i in 1..<sizes.count {
    let ratio = medians[i] / medians[i - 1]
    print("n = \(sizes[i]): \((ratio * 10).rounded() / 10) times the previous median")
}
