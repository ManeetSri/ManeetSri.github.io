// Generated from src/dsa/content/lessons/hashing/hash-pitfalls.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var readings: Set<Double> = []
readings.insert(.nan)
readings.insert(.nan)
print(readings.count, readings.contains(.nan))

let zeros: Set<Double> = [0.0, -0.0]
print(zeros.count)
