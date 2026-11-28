// Generated from src/dsa/content/lessons/tree-basics/tree-types.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

for height in 1...6 {
    let nodes = (1 << height) - 1          // 2^h - 1
    let leaves = 1 << (height - 1)         // 2^(h-1)
    print("height \(height): \(nodes) nodes, \(leaves) leaves")
}
print("height 20:", (1 << 20) - 1, "nodes")
