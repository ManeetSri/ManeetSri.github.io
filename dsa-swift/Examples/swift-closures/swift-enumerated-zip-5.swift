// Generated from src/dsa/content/lessons/swift-closures/swift-enumerated-zip.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let readings = [3, 5, 9, 8, 12]

let steps = zip(readings, readings.dropFirst()).map { $1 - $0 }
print(steps)

let isIncreasing = zip(readings, readings.dropFirst()).allSatisfy { $0 < $1 }
print(isIncreasing)
