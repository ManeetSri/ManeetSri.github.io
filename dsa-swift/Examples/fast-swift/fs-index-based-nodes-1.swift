// Generated from src/dsa/content/lessons/fast-swift/fs-index-based-nodes.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Node {
    var value: Int
    var next: Int          // index of the next node, or -1
}

struct OptionalNode {
    var value: Int
    var next: Int?
}

struct SmallNode {
    var value: Int32
    var next: Int32
}

print(MemoryLayout<Node>.stride, MemoryLayout<OptionalNode>.stride, MemoryLayout<SmallNode>.stride)
