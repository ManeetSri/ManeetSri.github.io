// Generated from src/dsa/content/lessons/swift-control-flow/swift-for-in.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let temperatures = [18, 21, 17, 24]

for i in 0..<temperatures.count {
    print("Day \(i + 1): \(temperatures[i])°")
}
