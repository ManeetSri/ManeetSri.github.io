// Generated from src/dsa/content/lessons/swift-tooling/swift-assertions-defer.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var depth = 0

func visit(_ n: Int) {
    depth += 1
    defer { depth -= 1 }
    print(String(repeating: "  ", count: depth - 1) + "visit \(n), depth \(depth)")
    if n > 1 {
        visit(n / 2)
    }
}

visit(8)
print("depth afterwards: \(depth)")
