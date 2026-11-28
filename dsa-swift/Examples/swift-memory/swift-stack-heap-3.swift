// Generated from src/dsa/content/lessons/swift-memory/swift-stack-heap.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let few = [1, 2, 3]
let many = Array(repeating: 0, count: 1_000)

print(MemoryLayout.size(ofValue: few))
print(MemoryLayout.size(ofValue: many))
