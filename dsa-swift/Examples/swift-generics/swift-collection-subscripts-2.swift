// Generated from src/dsa/content/lessons/swift-generics/swift-collection-subscripts.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

let scores = [70, 85, 92]
print(scores[safe: 1] ?? -1)
print(scores[safe: 10] ?? -1)
print(scores[safe: -1] ?? -1)
