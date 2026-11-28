// Generated from src/dsa/content/lessons/swift-memory/swift-stack-heap.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Point {
    var x: Int
    var y: Int
}

final class Marker {
    var x = 0
    var y = 0
}

print(MemoryLayout<Point>.size)
print(MemoryLayout<Marker>.size)
