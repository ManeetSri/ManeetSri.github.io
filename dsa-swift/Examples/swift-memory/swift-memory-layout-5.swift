// Generated from src/dsa/content/lessons/swift-memory/swift-memory-layout.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class Node {
    var value = 0
}

enum Direction {
    case north, east, south, west
}

print(MemoryLayout<Int?>.size, MemoryLayout<Int?>.stride)
print(MemoryLayout<Node>.size, MemoryLayout<Node?>.size)
print(MemoryLayout<Bool?>.size)
print(MemoryLayout<Direction>.size)
print(MemoryLayout<[Int]>.size, MemoryLayout<String>.size)
