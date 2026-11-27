// Generated from src/dsa/content/lessons/swift-control-flow/swift-for-in.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let readings = [12, 47, 8, 47, 30]
var largest = readings[0]
var position = 0

for i in 0..<readings.count {
    if readings[i] > largest {
        largest = readings[i]
        position = i
    }
}
print("Largest is \(largest), first seen at index \(position)")
