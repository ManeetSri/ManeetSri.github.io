// Generated from src/dsa/content/lessons/swift-optionals/swift-optionals-in-practice.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let laps = [62, 58, 65, 57, 60]
let noLaps: [Int] = []

print(laps.first ?? -1, laps.last ?? -1)
print(laps.min() ?? -1, laps.max() ?? -1)
print(noLaps.first ?? -1, noLaps.max() ?? -1)
