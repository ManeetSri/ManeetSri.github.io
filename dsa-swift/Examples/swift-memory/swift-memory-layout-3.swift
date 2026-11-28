// Generated from src/dsa/content/lessons/swift-memory/swift-memory-layout.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Packed {
    var count: Int
    var flag: Bool
    var done: Bool
}

print(MemoryLayout<Packed>.size)
print(MemoryLayout<Packed>.stride)
print(MemoryLayout<Packed>.offset(of: \.flag)!)
print(MemoryLayout<Packed>.offset(of: \.done)!)
