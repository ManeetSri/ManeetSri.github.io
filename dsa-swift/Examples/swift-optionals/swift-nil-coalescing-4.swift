// Generated from src/dsa/content/lessons/swift-optionals/swift-nil-coalescing.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let count: Int? = 5

print(count ?? 0 + 1)
print((count ?? 0) + 1)
