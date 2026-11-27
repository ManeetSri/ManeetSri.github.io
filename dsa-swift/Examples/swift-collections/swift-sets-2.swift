// Generated from src/dsa/content/lessons/swift-collections/swift-sets.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var tags = Set<String>()
tags.insert("swift")
tags.insert("ios")
tags.insert("swift")
print(tags.count)

print(tags.contains("ios"))
print(tags.contains("android"))

let removed = tags.remove("ios")
print(removed ?? "nothing")
print(tags.remove("android") ?? "nothing")
print(tags.count)
