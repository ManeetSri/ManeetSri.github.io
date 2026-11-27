// Generated from src/dsa/content/lessons/swift-collections/swift-collections-are-values.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let original = [1, 2, 3]
var copy = original
copy.append(4)
copy[0] = 100

print(original)
print(copy)
