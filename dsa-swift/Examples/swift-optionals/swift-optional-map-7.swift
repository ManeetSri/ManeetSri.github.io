// Generated from src/dsa/content/lessons/swift-optionals/swift-optional-map.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let word: String? = "optional"

print(word?.count == word.map { $0.count })
print(word.map { $0.count } ?? 0)
