// Generated from src/dsa/content/lessons/swift-control-flow/swift-break-continue.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let readings = [12, -1, 8, -1, 15]
var total = 0
var valid = 0

for reading in readings {
    if reading < 0 {
        continue // -1 means the sensor failed: skip it
    }
    total += reading
    valid += 1
}
print("Average of \(valid) readings: \(total / valid)")
