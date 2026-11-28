// Generated from src/dsa/content/lessons/tree-basics/tree-nary.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Node i's parent is parents[i]; the root has -1
let parents = [-1, 0, 0, 1, 1, 1, 2, 5]

var children = Array(repeating: [Int](), count: parents.count)
var root = -1
for (node, parent) in parents.enumerated() {
    if parent == -1 {
        root = node
    } else {
        children[parent].append(node)
    }
}

for node in children.indices where !children[node].isEmpty {
    print("\(node) has children \(children[node])")
}

var level = [root]
var depth = 0
while !level.isEmpty {
    print("depth \(depth): \(level)")
    level = level.flatMap { children[$0] }
    depth += 1
}
