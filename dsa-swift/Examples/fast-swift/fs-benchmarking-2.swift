// Generated from src/dsa/content/lessons/fast-swift/fs-benchmarking.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func median(_ values: [Double]) -> Double {
    values.sorted()[values.count / 2]
}

let before = [12.4, 12.1, 12.6, 12.2, 12.3]
let after = [11.9, 12.5, 12.0, 12.2, 12.1]
let change = (median(after) - median(before)) / median(before) * 100
print("change: \((change * 10).rounded() / 10)%")
