// Generated from src/dsa/content/lessons/swift-memory/swift-memory-layout.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Padded {
    var flag: Bool
    var count: Int
    var done: Bool
}

struct Packed {
    var count: Int
    var flag: Bool
    var done: Bool
}

let elements = 1_000
print(elements * MemoryLayout<Padded>.stride)
print(elements * MemoryLayout<Packed>.stride)
