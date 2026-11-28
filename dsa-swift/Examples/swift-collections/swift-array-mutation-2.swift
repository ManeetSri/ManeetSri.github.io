// Generated from src/dsa/content/lessons/swift-collections/swift-array-mutation.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let readings = [12, -3, 8, -1, 0, 5]
var positives: [Int] = []
for reading in readings {
    if reading > 0 {
        positives.append(reading)
    }
}
print(positives)
