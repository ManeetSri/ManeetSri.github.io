// Generated from src/dsa/content/lessons/swift-memory/swift-memory-layout.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Padded {
    var flag: Bool
    var count: Int
    var done: Bool
}

print(MemoryLayout<Padded>.size)
print(MemoryLayout<Padded>.stride)
print(MemoryLayout<Padded>.alignment)
print(MemoryLayout<Padded>.offset(of: \.flag)!)
print(MemoryLayout<Padded>.offset(of: \.count)!)
print(MemoryLayout<Padded>.offset(of: \.done)!)
