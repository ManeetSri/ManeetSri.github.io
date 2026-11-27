// Generated from src/dsa/content/lessons/swift-optionals/swift-why-nil.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let temperatures = [4, 7, 12, 9]
var firstFreezingDay = -1   // -1 means "none"

for i in 0..<temperatures.count {
    if temperatures[i] < 0 {
        firstFreezingDay = i
        break
    }
}
print(firstFreezingDay)
