// Generated from src/dsa/content/lessons/swift-library/lib-stdlib-algorithms.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var scores = [42, 7, 88, 15, 63, 91, 30]
let pivot = scores.partition { $0 >= 50 }
print(pivot)
print(scores)
print(scores[..<pivot].sorted(), scores[pivot...].sorted())

var steps = ["write", "test", "ship", "plan"]
steps.swapAt(0, 3)
print(steps)

var readings = [3, -1, 4, -1, 5, -9, 2]
readings.removeAll { $0 < 0 }
print(readings)
readings.reverse()
print(readings)
