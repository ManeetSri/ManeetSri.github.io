// Generated from src/dsa/design/content/lessons/sd-quality/sd-quality-performance.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

func percentile(_ p: Double, of samples: [Int]) -> Int {
    let sorted = samples.sorted()
    let rank = Int((p * Double(sorted.count) / 100).rounded(.up))
    return sorted[max(rank, 1) - 1]
}

// Twenty screen-load times in milliseconds: most are quick, two hit a slow network
let loads = [120, 135, 110, 150, 2900, 140, 125, 160, 130, 115, 145, 1400, 155, 105, 138, 128, 142, 118, 133, 147]
let mean = Double(loads.reduce(0, +)) / Double(loads.count)

print("mean: \(String(format: "%.1f", mean)) ms")
for p in [50.0, 90, 95, 99] {
    print("p\(Int(p)): \(percentile(p, of: loads)) ms")
}
