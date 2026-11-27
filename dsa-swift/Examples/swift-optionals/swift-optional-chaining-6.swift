// Generated from src/dsa/content/lessons/swift-optionals/swift-optional-chaining.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let name: String? = "Kai"

print(name?.count == 3)
print((name?.count ?? 0) > 5)
