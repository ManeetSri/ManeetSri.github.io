// Generated from src/dsa/content/lessons/interview-playbook/int-swift-gotchas.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let n = 100_000
let children = (0..<n).map { $0 + 1 < n ? [$0 + 1] : [] }   // one long path: 0 → 1 → … → 99,999
var stack = [(node: 0, depth: 1)]
var deepest = 0
while let (node, depth) = stack.popLast() {
    deepest = max(deepest, depth)
    for child in children[node] {
        stack.append((child, depth + 1))
    }
}
print(deepest)
