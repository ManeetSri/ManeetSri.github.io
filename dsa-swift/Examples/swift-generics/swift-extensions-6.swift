// Generated from src/dsa/content/lessons/swift-generics/swift-extensions.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

extension Array where Element == Int {
    var total: Int {
        reduce(0, +)
    }
}

print([3, 4, 5].total)
